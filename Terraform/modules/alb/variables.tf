# =============================================================================
# ALB Module Variables
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
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

variable "target_groups" {
  description = "List of target groups to create"
  type = list(object({
    name                  = string
    port                  = number
    protocol              = string
    target_type           = string
    health_check_path     = string
    health_check_matcher  = string
  }))
}

variable "listener_rules" {
  description = "List of listener rules"
  type = list(object({
    priority = number
    conditions = list(object({
      path_pattern = optional(object({
        values = list(string)
      }))
      host_header = optional(object({
        values = list(string)
      }))
      http_header = optional(object({
        name   = string
        values = list(string)
      }))
    }))
    actions = list(object({
      type             = string
      target_group_key = optional(string)
      redirect = optional(object({
        port        = string
        protocol    = string
        status_code = string
        host        = optional(string)
        path        = optional(string)
        query       = optional(string)
      }))
      fixed_response = optional(object({
        content_type = string
        message_body = string
        status_code  = string
      }))
    }))
  }))
  default = []
}

variable "default_target_group_key" {
  description = "Key of the default target group for HTTPS listener"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_https_redirect" {
  description = "Enable HTTP to HTTPS redirect"
  type        = bool
  default     = true
}

variable "enable_sticky_sessions" {
  description = "Enable sticky sessions"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "ALB idle timeout in seconds"
  type        = number
  default     = 60
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
