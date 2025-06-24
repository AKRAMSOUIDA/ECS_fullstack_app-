# =============================================================================
# ECR Module Variables
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "repositories" {
  description = "List of ECR repositories to create"
  type = list(object({
    name         = string
    scan_on_push = bool
    lifecycle_policy = optional(object({
      rules = list(object({
        rulePriority = number
        description  = string
        selection = object({
          tagStatus     = string
          tagPrefixList = optional(list(string))
          countType     = string
          countNumber   = number
        })
        action = object({
          type = string
        })
      }))
    }))
  }))
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
