# =============================================================================
# ALB Module - Application Load Balancer
# =============================================================================

# =============================================================================
# Application Load Balancer
# =============================================================================

resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  idle_timeout                     = var.idle_timeout

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb"
    Type = "Application Load Balancer"
  })
}

# =============================================================================
# Target Groups
# =============================================================================

resource "aws_lb_target_group" "target_groups" {
  for_each = { for tg in var.target_groups : tg.name => tg }

  name        = "${var.project_name}-${var.environment}-${each.value.name}-tg"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = each.value.health_check_path
    matcher             = each.value.health_check_matcher
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  # Enable stickiness if configured
  dynamic "stickiness" {
    for_each = var.enable_sticky_sessions ? [1] : []
    content {
      type            = "lb_cookie"
      cookie_duration = 86400
      enabled         = true
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${each.value.name}-tg"
    Type = "Target Group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# HTTP Listener (Redirect to HTTPS)
# =============================================================================

resource "aws_lb_listener" "http" {
  count = var.enable_https_redirect ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-http-listener"
  })
}

# =============================================================================
# HTTPS Listener
# =============================================================================

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  # Default action - forward to default target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_groups[var.default_target_group_key].arn
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-https-listener"
  })
}

# =============================================================================
# Listener Rules
# =============================================================================

resource "aws_lb_listener_rule" "rules" {
  count = length(var.listener_rules)

  listener_arn = aws_lb_listener.https.arn
  priority     = var.listener_rules[count.index].priority

  # Conditions
  dynamic "condition" {
    for_each = var.listener_rules[count.index].conditions
    content {
      dynamic "path_pattern" {
        for_each = lookup(condition.value, "path_pattern", null) != null ? [condition.value.path_pattern] : []
        content {
          values = path_pattern.value.values
        }
      }

      dynamic "host_header" {
        for_each = lookup(condition.value, "host_header", null) != null ? [condition.value.host_header] : []
        content {
          values = host_header.value.values
        }
      }

      dynamic "http_header" {
        for_each = lookup(condition.value, "http_header", null) != null ? [condition.value.http_header] : []
        content {
          http_header_name = http_header.value.name
          values           = http_header.value.values
        }
      }
    }
  }

  # Actions
  dynamic "action" {
    for_each = var.listener_rules[count.index].actions
    content {
      type             = action.value.type
      target_group_arn = action.value.type == "forward" ? aws_lb_target_group.target_groups[action.value.target_group_key].arn : null

      dynamic "redirect" {
        for_each = action.value.type == "redirect" ? [action.value.redirect] : []
        content {
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          status_code = redirect.value.status_code
          host        = lookup(redirect.value, "host", null)
          path        = lookup(redirect.value, "path", null)
          query       = lookup(redirect.value, "query", null)
        }
      }

      dynamic "fixed_response" {
        for_each = action.value.type == "fixed-response" ? [action.value.fixed_response] : []
        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-listener-rule-${count.index + 1}"
  })
}
