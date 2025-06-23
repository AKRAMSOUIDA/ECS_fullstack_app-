# =============================================================================
# ECR Module - Container Registry
# =============================================================================

# =============================================================================
# ECR Repositories
# =============================================================================

resource "aws_ecr_repository" "repositories" {
  for_each = { for repo in var.repositories : repo.name => repo }

  name                 = "${var.project_name}-${each.value.name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${each.value.name}"
    Type = "ECR Repository"
  })
}

# =============================================================================
# ECR Lifecycle Policies
# =============================================================================

resource "aws_ecr_lifecycle_policy" "policies" {
  for_each = { 
    for repo in var.repositories : repo.name => repo 
    if repo.lifecycle_policy != null 
  }

  repository = aws_ecr_repository.repositories[each.key].name

  policy = jsonencode({
    rules = each.value.lifecycle_policy.rules
  })
}

# =============================================================================
# ECR Repository Policies
# =============================================================================

data "aws_iam_policy_document" "ecr_policy" {
  for_each = { for repo in var.repositories : repo.name => repo }

  statement {
    sid    = "AllowPull"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }

  statement {
    sid    = "AllowPush"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  }
}

resource "aws_ecr_repository_policy" "policies" {
  for_each = { for repo in var.repositories : repo.name => repo }

  repository = aws_ecr_repository.repositories[each.key].name
  policy     = data.aws_iam_policy_document.ecr_policy[each.key].json
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}
