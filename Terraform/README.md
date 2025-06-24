# 🏗️ AWS MCP Fullstack Application - Terraform Infrastructure

This directory contains Terraform code to provision a complete AWS infrastructure for the fullstack Node.js and Next.js application with ECS, ALB, SSL/HTTPS, and auto-scaling capabilities.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Modules](#modules)
- [Outputs](#outputs)
- [Cost Estimation](#cost-estimation)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🏗️ Architecture Overview

This Terraform configuration creates the following AWS resources:

### **Core Infrastructure**
- **ECS Cluster**: Fargate-based container orchestration
- **Application Load Balancer**: High availability with SSL/HTTPS
- **ECR Repositories**: Container image registry for API and frontend
- **Security Groups**: Network security for ALB and ECS tasks
- **CloudWatch**: Logging and monitoring

### **SSL/HTTPS Configuration**
- **Self-signed Certificate**: Automatically generated and imported to ACM
- **HTTPS Listener**: Port 443 with SSL termination
- **HTTP Redirect**: Automatic redirect from HTTP to HTTPS

### **Auto Scaling**
- **CPU-based Scaling**: Automatic scaling based on CPU utilization
- **Memory-based Scaling**: Automatic scaling based on memory utilization
- **Configurable Limits**: Min/max capacity for both services

### **Monitoring & Logging**
- **CloudWatch Logs**: Centralized logging for both services
- **Container Insights**: Enhanced monitoring (optional)
- **Health Checks**: Application and load balancer level

## 📋 Prerequisites

### **Required Tools**
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [jq](https://stedolan.github.io/jq/) for JSON processing (optional, for deploy script)

### **AWS Permissions**
Your AWS credentials need the following permissions:
- ECS (full access)
- ECR (full access)
- EC2 (VPC, Security Groups, Load Balancers)
- IAM (roles and policies)
- CloudWatch (logs and metrics)
- ACM (certificate management)

### **Docker Images**
Ensure your Docker images are built and pushed to ECR:
```bash
# Build and push API image
docker build -t nodejs-api ./api
docker tag nodejs-api:latest <account-id>.dkr.ecr.<region>.amazonaws.com/nodejs-api:latest
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/nodejs-api:latest

# Build and push frontend image
docker build -t nextjs-frontend ./frontend
docker tag nextjs-frontend:latest <account-id>.dkr.ecr.<region>.amazonaws.com/nextjs-frontend:latest
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/nextjs-frontend:latest
```

## 🚀 Quick Start

### **1. Clone and Navigate**
```bash
cd /path/to/fullstack-app/Terraform
```

### **2. Configure Variables**
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

### **3. Deploy Infrastructure**
```bash
# Using the deployment script (recommended)
./deploy.sh

# Or manually
terraform init
terraform plan
terraform apply
```

### **4. Access Your Application**
After deployment, get the ALB DNS name:
```bash
terraform output alb_dns_name
```

Access your application at:
- **HTTPS**: `https://<alb-dns-name>`
- **HTTP**: `http://<alb-dns-name>` (redirects to HTTPS)

## ⚙️ Configuration

### **terraform.tfvars**
Key configuration options:

```hcl
# General
aws_region   = "us-east-1"
project_name = "fullstack-app"
environment  = "dev"

# ECS Resources
api_cpu           = 512
api_memory        = 1024
frontend_cpu      = 512
frontend_memory   = 1024

# Scaling
api_desired_count      = 2
frontend_desired_count = 2
enable_auto_scaling    = true

# Monitoring
log_retention_days        = 7
enable_container_insights = true
```

### **Environment-Specific Configurations**

#### **Development**
```hcl
environment             = "dev"
api_desired_count      = 1
frontend_desired_count = 1
enable_auto_scaling    = false
log_retention_days     = 3
```

#### **Production**
```hcl
environment                      = "prod"
api_desired_count               = 3
frontend_desired_count          = 3
enable_auto_scaling             = true
enable_deletion_protection      = true
log_retention_days              = 30
enable_container_insights       = true
```

## 🚀 Deployment

### **Using Deploy Script (Recommended)**
```bash
# Deploy infrastructure
./deploy.sh deploy

# Show deployment plan
./deploy.sh plan

# Show outputs
./deploy.sh output

# Destroy infrastructure
./deploy.sh destroy
```

### **Manual Deployment**
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply deployment
terraform apply tfplan

# Show outputs
terraform output
```

### **Deployment Steps**
1. **Validation**: Checks Terraform and AWS CLI
2. **Initialization**: Downloads providers and modules
3. **Planning**: Shows what will be created
4. **Confirmation**: Asks for user confirmation
5. **Application**: Creates AWS resources
6. **Outputs**: Shows important information

## 📦 Modules

### **ECR Module** (`modules/ecr/`)
- Creates ECR repositories for API and frontend
- Configures lifecycle policies
- Sets up repository policies

### **ALB Module** (`modules/alb/`)
- Creates Application Load Balancer
- Configures target groups
- Sets up HTTPS listener with SSL certificate
- Configures HTTP to HTTPS redirect

### **ECS Module** (`modules/ecs/`)
- Creates ECS cluster
- Defines task definitions for API and frontend
- Creates ECS services
- Configures auto-scaling policies

## 📤 Outputs

After deployment, Terraform provides these outputs:

```bash
# Application URLs
alb_dns_name = "fullstack-app-dev-alb-1234567890.us-east-1.elb.amazonaws.com"
application_urls = {
  "http"  = "http://fullstack-app-dev-alb-1234567890.us-east-1.elb.amazonaws.com"
  "https" = "https://fullstack-app-dev-alb-1234567890.us-east-1.elb.amazonaws.com"
}

# API endpoints
api_endpoints = {
  "health" = "https://fullstack-app-dev-alb-1234567890.us-east-1.elb.amazonaws.com/health"
  "users"  = "https://fullstack-app-dev-alb-1234567890.us-east-1.elb.amazonaws.com/api/users"
}

# ECR repositories
ecr_repositories = {
  "nodejs-api"      = "123456789012.dkr.ecr.us-east-1.amazonaws.com/fullstack-app-nodejs-api"
  "nextjs-frontend" = "123456789012.dkr.ecr.us-east-1.amazonaws.com/fullstack-app-nextjs-frontend"
}
```

## 💰 Cost Estimation

### **Monthly Cost Breakdown (us-east-1)**

#### **Development Environment**
- **ECS Fargate**: ~$25-35 (1 API + 1 Frontend task)
- **Application Load Balancer**: ~$16-22
- **CloudWatch Logs**: ~$2-5
- **ECR Storage**: ~$1-2
- **Total**: ~$45-65/month

#### **Production Environment**
- **ECS Fargate**: ~$75-100 (3 API + 3 Frontend tasks)
- **Application Load Balancer**: ~$16-22
- **CloudWatch Logs**: ~$5-10
- **ECR Storage**: ~$2-5
- **Total**: ~$100-140/month

### **Cost Optimization Tips**
- Use Spot instances for non-production (set `enable_spot_instances = true`)
- Reduce log retention for development environments
- Scale down during off-hours
- Use reserved capacity for predictable workloads

## 🔧 Troubleshooting

### **Common Issues**

#### **1. Terraform Init Fails**
```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Re-initialize
terraform init
```

#### **2. AWS Permissions Error**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify permissions
aws iam get-user
```

#### **3. ECS Tasks Not Starting**
```bash
# Check ECS service events
aws ecs describe-services --cluster <cluster-name> --services <service-name>

# Check task definition
aws ecs describe-task-definition --task-definition <task-definition-arn>
```

#### **4. Load Balancer Health Checks Failing**
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Check security groups
aws ec2 describe-security-groups --group-ids <security-group-id>
```

### **Debugging Commands**
```bash
# Show Terraform state
terraform show

# List all resources
terraform state list

# Show specific resource
terraform state show <resource-name>

# Refresh state
terraform refresh
```

## 🏆 Best Practices

### **Security**
- Use least privilege IAM policies
- Enable VPC Flow Logs for network monitoring
- Regularly update container images
- Use AWS Secrets Manager for sensitive data

### **Monitoring**
- Enable Container Insights for detailed metrics
- Set up CloudWatch alarms for critical metrics
- Use structured logging in applications
- Monitor costs with AWS Cost Explorer

### **Deployment**
- Use remote state storage (S3 + DynamoDB)
- Implement CI/CD pipelines
- Use separate environments (dev/staging/prod)
- Tag all resources consistently

### **Performance**
- Right-size your containers based on metrics
- Use Application Load Balancer health checks
- Implement proper caching strategies
- Monitor and optimize database queries

## 🔄 CI/CD Integration

### **GitHub Actions Example**
```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]
    paths: ['Terraform/**']

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init
        working-directory: ./Terraform
      - name: Terraform Plan
        run: terraform plan
        working-directory: ./Terraform
      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./Terraform
```

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [AWS Application Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

---

**Built with ❤️ using Terraform and AWS for enterprise-grade infrastructure as code**
