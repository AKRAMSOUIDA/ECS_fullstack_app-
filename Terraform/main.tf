# =============================================================================
# AWS MCP Fullstack Application - Terraform Infrastructure
# =============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# =============================================================================
# Provider Configuration
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "aws-mcp-nodejs-nextjs-ecs"
    }
  }
}

# =============================================================================
# Data Sources
# =============================================================================

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# Local Values
# =============================================================================

locals {
  # Common tags
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Application configuration
  app_name = "${var.project_name}-${var.environment}"
  
  # Get public subnets (subnets with internet gateway route)
  public_subnet_ids = [
    for subnet in data.aws_subnet.default : subnet.id
    if subnet.map_public_ip_on_launch
  ]

  # Container configuration
  api_container_name      = "nodejs-api"
  frontend_container_name = "nextjs-frontend"
  
  # Ports
  api_port      = 3001
  frontend_port = 3000
  http_port     = 80
  https_port    = 443
}

# =============================================================================
# ECR Repositories
# =============================================================================

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  
  repositories = [
    {
      name = "nodejs-api"
      scan_on_push = true
      lifecycle_policy = {
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 10 images"
            selection = {
              tagStatus     = "tagged"
              tagPrefixList = ["v"]
              countType     = "imageCountMoreThan"
              countNumber   = 10
            }
            action = {
              type = "expire"
            }
          }
        ]
      }
    },
    {
      name = "nextjs-frontend"
      scan_on_push = true
      lifecycle_policy = {
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 10 images"
            selection = {
              tagStatus     = "tagged"
              tagPrefixList = ["v"]
              countType     = "imageCountMoreThan"
              countNumber   = 10
            }
            action = {
              type = "expire"
            }
          }
        ]
      }
    }
  ]

  tags = local.common_tags
}

# =============================================================================
# Security Groups
# =============================================================================

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${local.app_name}-alb-"
  vpc_id      = data.aws_vpc.default.id
  description = "Security group for Application Load Balancer"

  # HTTP access from anywhere
  ingress {
    description = "HTTP"
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    description = "HTTPS"
    from_port   = local.https_port
    to_port     = local.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Security Group
resource "aws_security_group" "ecs" {
  name_prefix = "${local.app_name}-ecs-"
  vpc_id      = data.aws_vpc.default.id
  description = "Security group for ECS tasks"

  # API port from ALB
  ingress {
    description     = "API port from ALB"
    from_port       = local.api_port
    to_port         = local.api_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Frontend port from ALB
  ingress {
    description     = "Frontend port from ALB"
    from_port       = local.frontend_port
    to_port         = local.frontend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-ecs-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# SSL Certificate
# =============================================================================

# Generate private key
resource "tls_private_key" "alb_cert" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate self-signed certificate
resource "tls_self_signed_cert" "alb_cert" {
  private_key_pem = tls_private_key.alb_cert.private_key_pem

  subject {
    country             = "US"
    province            = "Virginia"
    locality            = "Arlington"
    organization        = "AWS-Demo"
    organizational_unit = "DevOps"
    common_name         = aws_lb.main.dns_name
  }

  # Certificate valid for 1 year
  validity_period_hours = 8760

  # Generate certificate for ALB DNS name
  dns_names = [
    aws_lb.main.dns_name
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  depends_on = [aws_lb.main]
}

# Import certificate to ACM
resource "aws_acm_certificate" "alb_cert" {
  private_key      = tls_private_key.alb_cert.private_key_pem
  certificate_body = tls_self_signed_cert.alb_cert.cert_pem

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-alb-certificate"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# Application Load Balancer
# =============================================================================

# =============================================================================
# Application Load Balancer
# =============================================================================

resource "aws_lb" "main" {
  name               = "${local.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  idle_timeout                     = var.idle_timeout

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-alb"
    Type = "Application Load Balancer"
  })
}

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment  = var.environment
  
  # Network configuration
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = local.public_subnet_ids
  
  # Security
  security_group_ids = [aws_security_group.alb.id]
  certificate_arn    = aws_acm_certificate.alb_cert.arn
  
  # Target groups configuration
  target_groups = [
    {
      name             = "nodejs-api"
      port             = local.api_port
      protocol         = "HTTP"
      target_type      = "ip"
      health_check_path = "/health"
      health_check_matcher = "200"
    },
    {
      name             = "nextjs-frontend"
      port             = local.frontend_port
      protocol         = "HTTP"
      target_type      = "ip"
      health_check_path = "/"
      health_check_matcher = "200"
    }
  ]

  # Listener rules
  listener_rules = [
    {
      priority = 100
      conditions = [
        {
          path_pattern = {
            values = ["/api/*", "/health"]
          }
        }
      ]
      actions = [
        {
          type             = "forward"
          target_group_key = "nodejs-api"
        }
      ]
    }
  ]

  # Default action (frontend)
  default_target_group_key = "nextjs-frontend"

  tags = local.common_tags
  
  depends_on = [aws_lb.main]
}

# =============================================================================
# ECS Cluster and Services
# =============================================================================

module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment  = var.environment
  
  # Network configuration
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = local.public_subnet_ids
  
  # Security
  security_group_ids = [aws_security_group.ecs.id]
  
  # ECR repositories
  api_repository_url      = module.ecr.repository_urls["nodejs-api"]
  frontend_repository_url = module.ecr.repository_urls["nextjs-frontend"]
  
  # Load balancer integration
  api_target_group_arn      = module.alb.target_group_arns["nodejs-api"]
  frontend_target_group_arn = module.alb.target_group_arns["nextjs-frontend"]
  
  # Application configuration
  api_container_name      = local.api_container_name
  frontend_container_name = local.frontend_container_name
  api_port               = local.api_port
  frontend_port          = local.frontend_port
  
  # Environment variables
  frontend_api_url = "https://${aws_lb.main.dns_name}"
  
  # Resource configuration
  api_cpu         = var.api_cpu
  api_memory      = var.api_memory
  frontend_cpu    = var.frontend_cpu
  frontend_memory = var.frontend_memory
  
  # Scaling configuration
  api_desired_count      = var.api_desired_count
  frontend_desired_count = var.frontend_desired_count

  tags = local.common_tags
  
  depends_on = [module.alb]
}

# =============================================================================
# CloudWatch Log Groups
# =============================================================================

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${local.app_name}-api"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-api-logs"
  })
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${local.app_name}-frontend"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-frontend-logs"
  })
}

# =============================================================================
# Outputs
# =============================================================================

# ALB DNS name (for accessing the application)
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

# Application URLs
output "application_urls" {
  description = "URLs to access the application"
  value = {
    http  = "http://${aws_lb.main.dns_name}"
    https = "https://${aws_lb.main.dns_name}"
  }
}

# API endpoints
output "api_endpoints" {
  description = "API endpoint URLs"
  value = {
    health = "https://${aws_lb.main.dns_name}/health"
    users  = "https://${aws_lb.main.dns_name}/api/users"
  }
}

# ECR repository URLs
output "ecr_repositories" {
  description = "ECR repository URLs for pushing images"
  value       = module.ecr.repository_urls
}

# ECS cluster information
output "ecs_cluster" {
  description = "ECS cluster information"
  value = {
    name = module.ecs.cluster_name
    arn  = module.ecs.cluster_arn
  }
}

# Security group IDs
output "security_groups" {
  description = "Security group IDs"
  value = {
    alb = aws_security_group.alb.id
    ecs = aws_security_group.ecs.id
  }
}

# Certificate ARN
output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.alb_cert.arn
}

# CloudWatch log groups
output "log_groups" {
  description = "CloudWatch log group names"
  value = {
    api      = aws_cloudwatch_log_group.api.name
    frontend = aws_cloudwatch_log_group.frontend.name
  }
}
