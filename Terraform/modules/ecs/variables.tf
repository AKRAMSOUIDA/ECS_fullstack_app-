# =============================================================================
# ECS Module Variables
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

# =============================================================================
# ECR Configuration
# =============================================================================

variable "api_repository_url" {
  description = "ECR repository URL for API"
  type        = string
}

variable "frontend_repository_url" {
  description = "ECR repository URL for frontend"
  type        = string
}

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

# =============================================================================
# Load Balancer Integration
# =============================================================================

variable "api_target_group_arn" {
  description = "Target group ARN for API service"
  type        = string
}

variable "frontend_target_group_arn" {
  description = "Target group ARN for frontend service"
  type        = string
}

# =============================================================================
# Container Configuration
# =============================================================================

variable "api_container_name" {
  description = "Name of the API container"
  type        = string
}

variable "frontend_container_name" {
  description = "Name of the frontend container"
  type        = string
}

variable "api_port" {
  description = "Port for API container"
  type        = number
}

variable "frontend_port" {
  description = "Port for frontend container"
  type        = number
}

variable "frontend_api_url" {
  description = "API URL for frontend to use"
  type        = string
}

# =============================================================================
# Resource Configuration
# =============================================================================

variable "api_cpu" {
  description = "CPU units for API task"
  type        = number
}

variable "api_memory" {
  description = "Memory (MB) for API task"
  type        = number
}

variable "frontend_cpu" {
  description = "CPU units for frontend task"
  type        = number
}

variable "frontend_memory" {
  description = "Memory (MB) for frontend task"
  type        = number
}

# =============================================================================
# Scaling Configuration
# =============================================================================

variable "api_desired_count" {
  description = "Desired number of API tasks"
  type        = number
}

variable "frontend_desired_count" {
  description = "Desired number of frontend tasks"
  type        = number
}

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
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

# =============================================================================
# Monitoring Configuration
# =============================================================================

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
