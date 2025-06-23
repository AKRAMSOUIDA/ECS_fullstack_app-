# 🔐 GitHub Secrets Setup Guide

## 📋 Required Secrets

### 🔑 AWS Credentials (Required)
- `AWS_ACCESS_KEY_ID` - AWS Access Key ID
- `AWS_SECRET_ACCESS_KEY` - AWS Secret Access Key  
- `AWS_ACCOUNT_ID` - 12-digit AWS Account ID
- `AWS_REGION` - AWS region (default: us-east-1)

### 🚢 ECS Configuration (Required)
- `ECS_CLUSTER_NAME` - ECS cluster name (default: fullstack-cluster)
- `ECS_EXECUTION_ROLE_ARN` - ECS task execution role ARN
- `ECS_API_SERVICE_NAME` - API service name (default: nodejs-api-service)
- `ECS_FRONTEND_SERVICE_NAME` - Frontend service name (default: nextjs-frontend-service)

### 🌐 Application Configuration (Required)
- `NEXT_PUBLIC_API_URL` - Public API URL for frontend

## 🛠️ How to Add Secrets

### GitHub Web Interface:
1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret with name and value

### GitHub CLI:
```bash
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_ACCESS_KEY"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET_KEY"
gh secret set AWS_ACCOUNT_ID --body "123456789012"
gh secret set AWS_REGION --body "us-east-1"
gh secret set ECS_CLUSTER_NAME --body "fullstack-cluster"
gh secret set ECS_EXECUTION_ROLE_ARN --body "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
gh secret set NEXT_PUBLIC_API_URL --body "https://your-alb-dns.elb.amazonaws.com"
```

## 🔍 How to Get Values

### AWS Account ID:
```bash
aws sts get-caller-identity --query Account --output text
```

### ECS Task Execution Role ARN:
```bash
aws iam get-role --role-name ecsTaskExecutionRole --query 'Role.Arn' --output text
```

### Load Balancer DNS:
```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].DNSName' --output text
```

## 📋 Secrets Checklist
- [ ] AWS_ACCESS_KEY_ID
- [ ] AWS_SECRET_ACCESS_KEY  
- [ ] AWS_ACCOUNT_ID
- [ ] AWS_REGION
- [ ] ECS_CLUSTER_NAME
- [ ] ECS_EXECUTION_ROLE_ARN
- [ ] NEXT_PUBLIC_API_URL
