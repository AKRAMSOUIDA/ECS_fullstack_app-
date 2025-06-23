# Fullstack App Deployment Guide

## Current Status ✅
- ✅ Node.js API running locally on port 3001
- ✅ Next.js frontend running locally on port 3000
- ✅ Docker images built and pushed to ECR
- ✅ Applications tested and working

## ECR Image URIs
- **API**: `391965905745.dkr.ecr.us-east-1.amazonaws.com/nodejs-api:latest`
- **Frontend**: `391965905745.dkr.ecr.us-east-1.amazonaws.com/nextjs-frontend:latest`

## Local Testing
Your applications are currently running locally:
- **API**: http://localhost:3001
- **Frontend**: http://localhost:3000

To stop local containers:
```bash
cd /home/ubuntu/fullstack-app
sudo docker compose down
```

## AWS Deployment Options

### Option 1: AWS ECS (Recommended for Production)

#### Manual ECS Deployment Steps:

1. **Create ECS Cluster**:
```bash
aws ecs create-cluster --cluster-name fullstack-cluster --region us-east-1
```

2. **Create Task Definition for API**:
```bash
aws ecs register-task-definition --region us-east-1 --cli-input-json '{
  "family": "nodejs-api-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::391965905745:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nodejs-api",
      "image": "391965905745.dkr.ecr.us-east-1.amazonaws.com/nodejs-api:latest",
      "portMappings": [
        {
          "containerPort": 3001,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nodejs-api",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}'
```

3. **Create Task Definition for Frontend**:
```bash
aws ecs register-task-definition --region us-east-1 --cli-input-json '{
  "family": "nextjs-frontend-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::391965905745:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nextjs-frontend",
      "image": "391965905745.dkr.ecr.us-east-1.amazonaws.com/nextjs-frontend:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "NEXT_PUBLIC_API_URL",
          "value": "http://your-api-alb-url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nextjs-frontend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}'
```

### Option 2: AWS App Runner (Simpler, but less control)

App Runner is easier to set up but offers less customization:

```bash
# Create App Runner service for API
aws apprunner create-service --region us-east-1 --cli-input-json '{
  "ServiceName": "nodejs-api-service",
  "SourceConfiguration": {
    "ImageRepository": {
      "ImageIdentifier": "391965905745.dkr.ecr.us-east-1.amazonaws.com/nodejs-api:latest",
      "ImageConfiguration": {
        "Port": "3001"
      },
      "ImageRepositoryType": "ECR"
    },
    "AutoDeploymentsEnabled": false
  },
  "InstanceConfiguration": {
    "Cpu": "0.25 vCPU",
    "Memory": "0.5 GB"
  }
}'
```

### Option 3: AWS Lambda + API Gateway (Serverless)

For serverless deployment, you'd need to modify your applications to work with Lambda handlers.

## Next Steps

1. **Choose your deployment method** (ECS recommended for full-stack apps)
2. **Set up VPC and networking** (subnets, security groups, load balancers)
3. **Configure environment variables** for production
4. **Set up monitoring and logging** with CloudWatch
5. **Configure CI/CD pipeline** for automated deployments

## Environment Variables for Production

### API Environment Variables:
- `NODE_ENV=production`
- `PORT=3001`
- Database connection strings (if using a database)

### Frontend Environment Variables:
- `NODE_ENV=production`
- `NEXT_PUBLIC_API_URL=https://your-api-domain.com`

## Security Considerations

1. **Use HTTPS** for all production traffic
2. **Configure CORS** properly for your frontend domain
3. **Set up proper IAM roles** with minimal permissions
4. **Use AWS Secrets Manager** for sensitive data
5. **Enable VPC security groups** to restrict access

## Monitoring

Set up CloudWatch alarms for:
- CPU and memory usage
- HTTP error rates
- Response times
- Container health checks

## Cost Optimization

- Use **AWS Graviton instances** for better price/performance
- Set up **auto-scaling** based on demand
- Consider **Spot instances** for non-critical workloads
- Monitor costs with **AWS Cost Explorer**
