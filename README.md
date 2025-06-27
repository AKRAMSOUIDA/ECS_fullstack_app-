# Fullstack app blueprint - Node.js & Next.js on ECS

A full-stack application demonstrating deployment of Node.js API and Next.js frontend on AWS ECS using containerization.

## 🏗️ Architecture

- **Backend**: Node.js Express API with health checks and user management
- **Frontend**: Next.js React application with API integration
- **Containerization**: Docker containers for both applications
- **Deployment**: AWS ECS with ECR for container registry
- **Load Balancing**: Application Load Balancer for high availability
- **Security**: SSL/HTTPS encryption with automatic HTTP redirect

## 📁 Project Structure

```
fullstack-app/
├── api/                    # Node.js Express API
│   ├── server.js          # Main server file
│   ├── package.json       # API dependencies
│   └── Dockerfile         # API container configuration
├── frontend/              # Next.js React application
│   ├── pages/
│   │   └── index.js       # Main page with user interface
│   ├── public/            # Static assets
│   ├── package.json       # Frontend dependencies
│   ├── next.config.js     # Next.js configuration
│   └── Dockerfile         # Frontend container configuration
├── docker-compose.yml     # Local development setup
├── deployment-guide.md    # Detailed deployment instructions
└── README.md             # This file
```

## 🚀 Features

### Node.js API (Port 3001)
- **Health Check**: `GET /health` - Application health status
- **User Management**: 
  - `GET /api/users` - Retrieve all users
  - `POST /api/users` - Create new user
- **CORS Support**: Cross-origin requests enabled
- **Production Ready**: Optimized Docker container

### Next.js Frontend (Port 3000)
- **User Interface**: Interactive user management
- **API Integration**: Real-time communication with backend
- **Responsive Design**: Works on desktop and mobile
- **Production Build**: Optimized for deployment

## 🛠️ Local Development

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ (for local development)

### Quick Start
```bash
# Clone and navigate to project
cd fullstack-app

# Start both applications
docker compose up --build

# Access applications
# API: http://localhost:3001
# Frontend: http://localhost:3000
```

### Individual Services
```bash
# API only
cd api
npm install
npm start

# Frontend only
cd frontend
npm install
npm run dev
```

## 🌐 AWS Deployment

### ECR Container Registry
- **API**: `<account-id>.dkr.ecr.<region>.amazonaws.com/nodejs-api:latest`
- **Frontend**: `<account-id>.dkr.ecr.<region>.amazonaws.com/nextjs-frontend:latest`

### Deployment Options

#### 1. AWS ECS 
- Full container orchestration
- Auto-scaling capabilities
- Load balancer integration
- Production-grade monitoring


See `deployment-guide.md` for detailed instructions.

## 🔧 Configuration

### Environment Variables

#### API
- `NODE_ENV`: Environment (development/production)
- `PORT`: Server port (default: 3001)

#### Frontend
- `NEXT_PUBLIC_API_URL`: Backend API URL
- `NODE_ENV`: Environment (development/production)

### Docker Configuration
- **Multi-stage builds** for optimized images
- **Non-root users** for security
- **Health checks** for container monitoring
- **Alpine Linux** for minimal image size

## 📊 Monitoring & Observability

### Health Checks
- API health endpoint: `/health`
- Docker container health checks
- Load balancer health monitoring

### Logging
- Structured JSON logging
- CloudWatch integration
- Container-level log aggregation

## 🔒 Security Features

- **CORS Configuration**: Proper cross-origin handling
- **Non-root Containers**: Enhanced security
- **Environment Variables**: Secure configuration management
- **VPC Networking**: Isolated network environment
- **SSL/HTTPS**: End-to-end encryption
- **HTTP to HTTPS Redirect**: Automatic secure connections

## 🚦 API Endpoints

### Health Check
```http
GET /health
Response: {"status": "OK", "timestamp": "2025-06-23T10:28:59.280Z"}
```

### Users
```http
GET /api/users
Response: [{"id": 1, "name": "John Doe", "email": "john@example.com"}]

POST /api/users
Body: {"name": "New User", "email": "user@example.com"}
Response: {"id": 123456789, "name": "New User", "email": "user@example.com"}
```

## 🎯 Performance Optimizations

- **Container Optimization**: Multi-stage Docker builds
- **Next.js Optimization**: Static generation and code splitting
- **Caching**: Efficient Docker layer caching
- **Resource Limits**: Proper CPU and memory allocation
- **Load Balancing**: Application Load Balancer with health checks
- **HTTP/2**: Modern protocol support with SSL/HTTPS

## 📈 Scaling Considerations

- **Horizontal Scaling**: Multiple container instances
- **Load Balancing**: Application Load Balancer
- **Auto Scaling**: Based on CPU/memory metrics
- **Database**: Consider RDS for persistent data


## 📚 Technologies Used

- **Backend**: Node.js, Express.js
- **Frontend**: Next.js, React
- **Containerization**: Docker, Docker Compose
- **Cloud**: AWS ECS, ECR, ALB
- **Security**: SSL/HTTPS, ACM certificates
- **Monitoring**: CloudWatch, Health Checks

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker Compose
5. Submit a pull request


