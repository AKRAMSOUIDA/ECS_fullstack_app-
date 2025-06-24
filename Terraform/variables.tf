# =============================================================================
# AWS MCP Fullstack Application - Terraform Variables
# =============================================================================

# =============================================================================
# General Configuration
# =============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fullstack-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# =============================================================================
# Network Configuration
# =============================================================================

variable "vpc_id" {
  description = "VPC ID to deploy resources (optional, uses default VPC if not provided)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for deployment (optional, uses default subnets if not provided)"
  type        = list(string)
  default     = []
}

# =============================================================================
# ECS Configuration
# =============================================================================

variable "api_cpu" {
  description = "CPU units for API task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
  
  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.api_cpu)
    error_message = "API CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "api_memory" {
  description = "Memory (MB) for API task"
  type        = number
  default     = 1024
  
  validation {
    condition     = var.api_memory >= 512 && var.api_memory <= 30720
    error_message = "API memory must be between 512 and 30720 MB."
  }
}

variable "frontend_cpu" {
  description = "CPU units for frontend task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
  
  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.frontend_cpu)
    error_message = "Frontend CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "frontend_memory" {
  description = "Memory (MB) for frontend task"
  type        = number
  default     = 1024
  
  validation {
    condition     = var.frontend_memory >= 512 && var.frontend_memory <= 30720
    error_message = "Frontend memory must be between 512 and 30720 MB."
  }
}

variable "api_desired_count" {
  description = "Desired number of API tasks"
  type        = number
  default     = 2
  
  validation {
    condition     = var.api_desired_count >= 1 && var.api_desired_count <= 10
    error_message = "API desired count must be between 1 and 10."
  }
}

variable "frontend_desired_count" {
  description = "Desired number of frontend tasks"
  type        = number
  default     = 2
  
  validation {
    condition     = var.frontend_desired_count >= 1 && var.frontend_desired_count <= 10
    error_message = "Frontend desired count must be between 1 and 10."
  }
}

# =============================================================================
# Application Configuration
# =============================================================================

variable "api_image_tag" {
  description = "Docker image tag for API"
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "Docker image tag for frontend"
  type        = string
  default     = "latest"
}

variable "domain_name" {
  description = "Custom domain name for the application (optional)"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain (optional)"
  type        = string
  default     = null
}

# =============================================================================
# Load Balancer Configuration
# =============================================================================

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "ALB idle timeout in seconds"
  type        = number
  default     = 60
  
  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "Idle timeout must be between 1 and 4000 seconds."
  }
}

# =============================================================================
# Security Configuration
# =============================================================================

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_waf" {
  description = "Enable AWS WAF for the ALB"
  type        = bool
  default     = false
}

# =============================================================================
# Monitoring Configuration
# =============================================================================

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

# =============================================================================
# Auto Scaling Configuration
# =============================================================================

variable "enable_auto_scaling" {
  description = "Enable auto scaling for ECS services"
  type        = bool
  default     = true
}

variable "api_min_capacity" {
  description = "Minimum number of API tasks for auto scaling"
  type        = number
  default     = 1
}

variable "api_max_capacity" {
  description = "Maximum number of API tasks for auto scaling"
  type        = number
  default     = 10
}

variable "frontend_min_capacity" {
  description = "Minimum number of frontend tasks for auto scaling"
  type        = number
  default     = 1
}

variable "frontend_max_capacity" {
  description = "Maximum number of frontend tasks for auto scaling"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
  
  validation {
    condition     = var.cpu_target_value >= 10 && var.cpu_target_value <= 90
    error_message = "CPU target value must be between 10 and 90 percent."
  }
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
  
  validation {
    condition     = var.memory_target_value >= 10 && var.memory_target_value <= 90
    error_message = "Memory target value must be between 10 and 90 percent."
  }
}

# =============================================================================
# Backup and Disaster Recovery
# =============================================================================

variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# =============================================================================
# Cost Optimization
# =============================================================================

variable "enable_spot_instances" {
  description = "Enable Spot instances for cost optimization (not recommended for production)"
  type        = bool
  default     = false
}

variable "spot_allocation_strategy" {
  description = "Spot allocation strategy (diversified, balanced)"
  type        = string
  default     = "diversified"
  
  validation {
    condition     = contains(["diversified", "balanced"], var.spot_allocation_strategy)
    error_message = "Spot allocation strategy must be either 'diversified' or 'balanced'."
  }
}

# =============================================================================
# Tags
# =============================================================================

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Feature Flags
# =============================================================================

variable "enable_https_redirect" {
  description = "Enable automatic HTTP to HTTPS redirect"
  type        = bool
  default     = true
}

variable "enable_sticky_sessions" {
  description = "Enable sticky sessions for load balancer"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

# =============================================================================
# Development Configuration
# =============================================================================

variable "enable_debug_mode" {
  description = "Enable debug mode for development"
  type        = bool
  default     = false
}

variable "enable_hot_reload" {
  description = "Enable hot reload for development (requires debug mode)"
  type        = bool
  default     = false
}
