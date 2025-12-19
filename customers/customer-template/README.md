# Customer Template

This is atemplate directory for onboarding new customers. Follow these steps to set up infrastructure for a new customer.

## Quick Start

### 1. Copy this Template

```bash
cd ../../customers
cp -r customer-template <customer-name>
cd <customer-name>
```

### 2. Create Backend Configuration

Create separate backend config files for each environment:

**backend-config-dev.tfvars:**
```hcl
bucket = "<customer-name>-terraform-state"
prefix = "dev"
```

**backend-config-staging.tfvars:**
```hcl
bucket = "<customer-name>-terraform-state"
prefix = "staging"
```

**backend-config-prod.tfvars:**
```hcl
bucket = "<customer-name>-terraform-state"
prefix = "prod"
```

### 3. Create Terraform Variables File

Copy the template and customize:

```bash
cp terraform.tfvars.template terraform.tfvars
# Edit terraform.tfvars with customer-specific values
```

### 4. Initialize Terraform

```bash
cd ../../environments/dev
terraform init -backend-config=../../customers/<customer-name>/backend-config-dev.tfvars
```

### 5. Plan and Apply

```bash
# Copy customer tfvars to environment
cp ../../customers/<customer-name>/terraform.tfvars .

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

## Automated Deployment

Use the helper scripts:

```bash
# Create customer workspace
../../scripts/new-customer.sh <customer-name>

# Deploy specific environment
../../scripts/deploy.sh <customer-name> dev
```

## File Structure

```
customer-name/
├── README.md                      # This file
├── backend-config-dev.tfvars      # Dev backend config
├── backend-config-staging.tfvars  # Staging backend config
├── backend-config-prod.tfvars     # Prod backend config
└── terraform.tfvars.template      # Variable values template
```

## Best Practices

1. **Never commit `terraform.tfvars`** - Contains sensitive customer data
2. **Use separate GCS buckets per customer** - Isolate state files
3. **Enable versioning on state buckets** - Protect against accidental deletion
4. **Test in dev first** - Always validate in dev before promoting to prod
5. **Document customizations** - Update this README with customer-specific notes
