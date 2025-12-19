#!/bin/bash

# Script to deploy Terraform for a specific customer and environment
# Usage: ./deploy.sh <customer-name> <environment> [plan-only]

set -e

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <customer-name> <environment> [plan-only]"
    echo "Example: $0 acme-corp dev"
    echo "Example: $0 acme-corp prod plan-only"
    echo ""
    echo "Environments: dev, staging, prod"
    exit 1
fi

CUSTOMER_NAME=$1
ENVIRONMENT=$2
PLAN_ONLY=${3:-""}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CUSTOMER_DIR="$REPO_ROOT/customers/$CUSTOMER_NAME"
ENV_DIR="$REPO_ROOT/environments/$ENVIRONMENT"

# Validate inputs
if [ ! -d "$CUSTOMER_DIR" ]; then
    echo "Error: Customer directory not found: $CUSTOMER_DIR"
    echo "Run ./new-customer.sh $CUSTOMER_NAME first"
    exit 1
fi

if [ ! -d "$ENV_DIR" ]; then
    echo "Error: Environment directory not found: $ENV_DIR"
    echo "Valid environments: dev, staging, prod"
    exit 1
fi

if [ ! -f "$CUSTOMER_DIR/terraform.tfvars" ]; then
    echo "Error: terraform.tfvars not found in $CUSTOMER_DIR"
    echo "Copy terraform.tfvars.template to terraform.tfvars and customize it"
    exit 1
fi

BACKEND_CONFIG="$CUSTOMER_DIR/backend-config-${ENVIRONMENT}.tfvars"
if [ ! -f "$BACKEND_CONFIG" ]; then
    echo "Error: Backend config not found: $BACKEND_CONFIG"
    exit 1
fi

echo "========================================="
echo "Deploying Terraform Configuration"
echo "========================================="
echo "Customer:    $CUSTOMER_NAME"
echo "Environment: $ENVIRONMENT"
echo "========================================="
echo ""

# Change to environment directory
cd "$ENV_DIR"

# Initialize Terraform with backend config
echo "Initializing Terraform..."
terraform init -reconfigure -backend-config="$BACKEND_CONFIG"

# Copy customer tfvars
echo "Copying customer variables..."
cp "$CUSTOMER_DIR/terraform.tfvars" .

# Validate configuration
echo "Validating configuration..."
terraform validate

# Format check
echo "Checking formatting..."
terraform fmt -check -recursive || true

# Plan
echo "Planning deployment..."
terraform plan -out=tfplan

if [ "$PLAN_ONLY" == "plan-only" ]; then
    echo ""
    echo "✅ Plan complete! Review the plan above."
    echo "To apply: cd $ENV_DIR && terraform apply tfplan"
    exit 0
fi

# Prompt for confirmation
echo ""
read -p "Do you want to apply this plan? (yes/no): " -r
echo ""

if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Applying plan..."
    terraform apply tfplan
    
    echo ""
    echo "✅ Deployment complete!"
    echo ""
    echo "To view outputs:"
    echo "  terraform output"
else
    echo "Deployment cancelled."
    exit 0
fi
