# =============================================================================
# ECR Module Outputs
# =============================================================================

output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for name, repo in aws_ecr_repository.repositories : 
    replace(name, "${var.project_name}-", "") => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for name, repo in aws_ecr_repository.repositories : 
    replace(name, "${var.project_name}-", "") => repo.arn
  }
}

output "repository_registry_ids" {
  description = "Map of repository names to their registry IDs"
  value = {
    for name, repo in aws_ecr_repository.repositories : 
    replace(name, "${var.project_name}-", "") => repo.registry_id
  }
}
