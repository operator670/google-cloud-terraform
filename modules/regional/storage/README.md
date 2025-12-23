# Regional Storage Module

This module creates regional Google Cloud Storage resources including:

- GCS buckets with regional storage class
- Lifecycle policies
- IAM bindings
- Versioning and retention policies

## Usage

```hcl
module "storage" {
  source = "../../modules/regional/storage"
  
  project_id    = var.project_id
  location      = var.region  # e.g., asia-south1
  
  bucket_name   = "my-customer-data"
  storage_class = "REGIONAL"
  
  versioning_enabled = true
  labels             = var.labels
}
```

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :--- |
| `project_id` | GCP Project ID | `string` | - | yes |
| `location` | GCP Region (e.g., asia-south1) | `string` | - | yes |
| `bucket_name` | Name of the storage bucket | `string` | - | yes |
| `storage_class` | Storage class (`REGIONAL`, `STANDARD`) | `string` | `REGIONAL` | no |
| `versioning_enabled` | Enable object versioning | `bool` | `false` | no |

## Outputs

| Name | Description |
| :--- | :--- |
| `bucket_name` | Bucket name |
| `bucket_url` | Bucket URL |
| `bucket_self_link` | Bucket self link |
