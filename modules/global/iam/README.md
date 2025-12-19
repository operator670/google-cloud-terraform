# Global IAM Module

This module creates global IAM resources including:
- Service Accounts
- IAM role bindings (project-level and service account-level)
- Service account keys
- Workload Identity bindings for GKE

## Usage

```hcl
module "iam" {
  source = "../../modules/global/iam"
  
  project_id = var.project_id
  
  service_accounts = [
    {
      account_id   = "app-service-account"
      display_name = "Application Service Account"
      description  = "Service account for application workloads"
    }
  ]
  
  project_iam_bindings = [
    {
      role    = "roles/storage.objectViewer"
      members = ["serviceAccount:app-service-account@${var.project_id}.iam.gserviceaccount.com"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| service_accounts | List of service accounts to create | list(object) | [] | no |
| project_iam_bindings | Project-level IAM bindings | list(object) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| service_account_emails | Map of service account emails |
| service_account_ids | Map of service account IDs |
