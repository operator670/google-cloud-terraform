#!/bin/bash

# Script to create a new customer workspace from template
# Usage: ./new-customer.sh <customer-name>

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <customer-name>"
    echo "Example: $0 acme-corp"
    exit 1
fi

CUSTOMER_NAME=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CUSTOMER_DIR="$REPO_ROOT/customers/$CUSTOMER_NAME"
TEMPLATE_DIR="$REPO_ROOT/customers/customer-template"

echo "Creating new customer workspace for: $CUSTOMER_NAME"

# Check if customer directory already exists
if [ -d "$CUSTOMER_DIR" ]; then
    echo "Error: Customer directory already exists: $CUSTOMER_DIR"
    exit 1
fi

# Copy template to new customer directory
echo "Copying template..."
cp -r "$TEMPLATE_DIR" "$CUSTOMER_DIR"

# Create backend configuration files
echo "Creating backend configuration files..."

cat > "$CUSTOMER_DIR/backend-config-dev.tfvars" <<EOF
bucket = "${CUSTOMER_NAME}-terraform-state"
prefix = "dev"
EOF

cat > "$CUSTOMER_DIR/backend-config-staging.tfvars" <<EOF
bucket = "${CUSTOMER_NAME}-terraform-state"
prefix = "staging"
EOF

cat > "$CUSTOMER_DIR/backend-config-prod.tfvars" <<EOF
bucket = "${CUSTOMER_NAME}-terraform-state"
prefix = "prod"
EOF

# Update terraform.tfvars.template with customer name
sed -i "s/CUSTOMER_NAME/$CUSTOMER_NAME/g" "$CUSTOMER_DIR/terraform.tfvars.template"

echo ""
echo "✅ Customer workspace created successfully!"
echo ""
echo "Next steps:"
echo "1. cd $CUSTOMER_DIR"
echo "2. Copy terraform.tfvars.template to terraform.tfvars"
echo "3. Edit terraform.tfvars with customer-specific values"
echo "4. Create GCS bucket for Terraform state:"
echo "   gsutil mb -p YOUR_PROJECT_ID -l asia-south1 gs://${CUSTOMER_NAME}-terraform-state"
echo "   gsutil versioning set on gs://${CUSTOMER_NAME}-terraform-state"
echo "5. Initialize Terraform:"
echo "   cd ../../environments/dev"
echo "   terraform init -backend-config=../../customers/$CUSTOMER_NAME/backend-config-dev.tfvars"
echo ""
