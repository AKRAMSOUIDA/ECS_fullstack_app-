# 🚀 CI/CD Pipeline Documentation

## 📋 Overview

Comprehensive CI/CD pipeline using GitHub Actions for automated testing, building, and deployment to AWS ECS.

## 🔄 Workflows

### 1. **Deploy Fullstack Application** (`deploy.yml`)
- **Triggers**: Push to main branch, PR, manual dispatch
- **Features**: Change detection, testing, security scanning, ECR push, ECS deployment

### 2. **Terraform Infrastructure** (`terraform.yml`)  
- **Triggers**: Terraform file changes, manual dispatch
- **Features**: Validation, planning, manual approval for apply/destroy

### 3. **Pull Request Checks** (`pr-check.yml`)
- **Triggers**: Pull requests
- **Features**: Code quality, security scanning, build tests

## 🔐 Required Secrets

See [SECRETS_SETUP.md](SECRETS_SETUP.md) for setup instructions.

Essential secrets:
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID` 
- `ECS_EXECUTION_ROLE_ARN`
- `NEXT_PUBLIC_API_URL`

## 🚀 Usage

### Automatic: Push to main branch
### Manual: Actions tab → Run workflow
### Infrastructure: Terraform workflow with approval

## 🔧 Features

- Smart change detection
- Zero-downtime deployments  
- Security scanning
- Health checks
- Environment management

**🚀 Ready for enterprise-grade automated deployments!**
