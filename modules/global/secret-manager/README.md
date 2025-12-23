# Secret Manager Module

This module manages Google Cloud Secret Manager secrets, versions, and IAM access.

## Features

- Create secrets with automatic or user-managed replication.
- Create secret versions (initial data).
- Manage IAM access (Secret Manager Secret Accessor, etc.) at the secret level.

## Usage

```hcl
module "secrets" {
  source     = "../../modules/global/secret-manager"
  project_id = var.project_id

  secrets = {
    "db-password" = {
      secret_id = "database-password"
      labels    = { component = "database" }
      versions = [
        {
          version_id  = "v1"
          secret_data = "super-secret-password"
        }
      ]
      iam_bindings = [
        {
          role    = "roles/secretmanager.secretAccessor"
          members = ["serviceAccount:my-sa@my-project.iam.gserviceaccount.com"]
        }
      ]
    }
  }
}
```
