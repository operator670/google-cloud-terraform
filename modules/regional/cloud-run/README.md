# Regional Cloud Run Module

This module deploys Cloud Run services for serverless containerized applications.

## Features

- Cloud Run services with auto-scaling
- IAM bindings for service access
- Custom domains and SSL
- VPC connector integration
- Environment variables and secrets
- CPU and memory limits
- Concurrency and timeout settings

## Usage

```hcl
module "cloud_run" {
  source = "../../modules/regional/cloud-run"
  
  project_id = var.project_id
  region     = "asia-south1"
  
  service_name = "my-api"
  
  image = "gcr.io/project-id/my-app:latest"
  
  # Environment variables
  env_vars = [
    {
      name  = "DATABASE_URL"
      value = "postgresql://..."
    }
  ]
  
  # Resource limits
  cpu_limit    = "1000m"
  memory_limit = "512Mi"
  
  # Auto-scaling
  min_instances = 0
  max_instances = 10
  
  # Make publicly accessible
  allow_unauthenticated = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| region | GCP Region | string | - | yes |
| service_name | Name of Cloud Run service | string | - | yes |
| image | Container image | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| service_url | Cloud Run service URL |
| service_id | Service ID |
