# Development Environment

This environment consumes the **Standard Composition Blueprint**.
Architecture changes should be made in `modules/composition/environment`.

## 🛠 Configuration
Configuration is split into domain-specific files for clarity:

| File | Purpose |
| :--- | :--- |
| `common.auto.tfvars` | Project ID, Region, Labels |
| `compute.auto.tfvars` | VM definitions, Spot settings, Schedules |
| `database.auto.tfvars` | Cloud SQL instances, Users, Passwords (via Secret ID) |
| `networking.auto.tfvars` | NAT settings, Subnets |
| `firewall.auto.tfvars` | **Custom** Firewall rules specific to Dev |
| `gke.auto.tfvars` | Kubernetes Clusters & Node Pools |
| `storage.auto.tfvars` | GCS Buckets & Lifecycle Policies |

## 🔐 Secrets
Do **NOT** put plain text passwords in `database.auto.tfvars`.
Instead, create a secret in GCP Secret Manager and reference it:
```hcl
password_secret_id = "projects/my-project/secrets/my-db-pass/versions/1"
```

## ⚠️ Drift Warning
If you manually change resources in the Dev Project:
1.  Run `terraform plan` to see the drift.
2.  Review if you want to keep it (update tfvars) or revert it (terraform apply).
