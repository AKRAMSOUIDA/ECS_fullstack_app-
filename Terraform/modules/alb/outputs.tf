# =============================================================================
# ALB Module Outputs
# =============================================================================

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arns" {
  description = "Map of target group names to their ARNs"
  value = {
    for name, tg in aws_lb_target_group.target_groups : name => tg.arn
  }
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener (if redirect is enabled)"
  value       = var.enable_https_redirect ? aws_lb_listener.http[0].arn : null
}
