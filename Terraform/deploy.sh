#!/bin/bash

# =============================================================================
# Terraform Deployment Script
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform is installed
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    log_info "Terraform version: $(terraform version -json | jq -r '.terraform_version')"
}

# Check if AWS CLI is configured
check_aws() {
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    log_info "AWS Account: $(aws sts get-caller-identity --query Account --output text)"
    log_info "AWS Region: $(aws configure get region)"
}

# Initialize Terraform
terraform_init() {
    log_info "Initializing Terraform..."
    terraform init
    log_success "Terraform initialized successfully"
}

# Plan Terraform deployment
terraform_plan() {
    log_info "Planning Terraform deployment..."
    terraform plan -out=tfplan
    log_success "Terraform plan completed successfully"
}

# Apply Terraform deployment
terraform_apply() {
    log_info "Applying Terraform deployment..."
    terraform apply tfplan
    log_success "Terraform deployment completed successfully"
}

# Show outputs
show_outputs() {
    log_info "Deployment outputs:"
    terraform output -json | jq '.'
}

# Main deployment function
deploy() {
    log_info "Starting Terraform deployment..."
    
    # Pre-deployment checks
    check_terraform
    check_aws
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        log_warning "terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        log_warning "Please edit terraform.tfvars with your configuration before proceeding."
        read -p "Press Enter to continue after editing terraform.tfvars..."
    fi
    
    # Terraform deployment
    terraform_init
    terraform_plan
    
    # Confirm before applying
    echo
    log_warning "This will create AWS resources that may incur costs."
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform_apply
        show_outputs
        
        echo
        log_success "Deployment completed successfully!"
        log_info "Your application will be available at the ALB DNS name shown above."
        log_info "Note: It may take a few minutes for the services to become healthy."
    else
        log_info "Deployment cancelled."
        rm -f tfplan
    fi
}

# Destroy function
destroy() {
    log_warning "This will destroy all AWS resources created by Terraform."
    read -p "Are you sure you want to destroy the infrastructure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Destroying Terraform infrastructure..."
        terraform destroy
        log_success "Infrastructure destroyed successfully"
    else
        log_info "Destroy cancelled."
    fi
}

# Help function
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  deploy    Deploy the infrastructure (default)"
    echo "  destroy   Destroy the infrastructure"
    echo "  plan      Show deployment plan"
    echo "  output    Show deployment outputs"
    echo "  help      Show this help message"
    echo
    echo "Examples:"
    echo "  $0 deploy    # Deploy infrastructure"
    echo "  $0 destroy   # Destroy infrastructure"
    echo "  $0 plan      # Show what will be deployed"
}

# Main script logic
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    destroy)
        destroy
        ;;
    plan)
        check_terraform
        check_aws
        terraform_init
        terraform plan
        ;;
    output)
        show_outputs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
