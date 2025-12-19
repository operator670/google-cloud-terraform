# Google Cloud Platform Infrastructure

This repository contains the Terraform codebase for managing the Multi-Customer Google Cloud Platform (GCP) infrastructure. It is designed using the **Composition Module Pattern** to ensure consistency, scalability, and strict governance across Development, Staging, and Production environments.

## 🏗️ Architecture

The infrastructure adopts a **Unified Blueprint Architecture** to maximize code reuse and eliminate configuration drift.

### 1. Composition Blueprint (`modules/composition`)
The core architectural logic is centralized in the `modules/composition/environment` module. This "Blueprint" defines the standard reference architecture (VPC, Compute, GKE, Databases, IAM) that is instantiated across all environments. Changes made to this blueprint are automatically propagated, ensuring that `dev` and `prod` remain architecturally consistent.

### 2. Environment Configurations (`environments/*`)
Environments are purposefully lightweight. They consume the **Composition Blueprint** and apply environment-specific configurations via variables (e.g., machine types, cluster sizes, high-availability settings).

### 3. Service Modules (`modules/{global,regional}`)
Granular, reusable modules for individual GCP services:
-   **Global**: Networking (VPC, Firewall, NAT), IAM, Secret Manager.
-   **Regional**: Compute Engine, GKE, Cloud SQL, Cloud Storage.

---

## 🚀 Getting Started

### 1. Backend Configuration
Sensitive state bucket configurations are decoupled from the code using partial backend configurations.

```bash
cd environments/dev
# Initialize Terraform with the dev backend config
terraform init -backend-config=../../backend-configs/dev.tfvars
```

### 2. Resource Configuration
We use **Split Variables** (`*.auto.tfvars`) for cleaner organization. Terraform automatically loads all files matching `*.auto.tfvars`.

-   `compute.auto.tfvars`: VM instances and scheduling.
-   `database.auto.tfvars`: Cloud SQL instances and users.
-   `gke.auto.tfvars`: Kubernetes clusters and node pools.

### 3. Deployment
```bash
# Preview changes
terraform plan

# Apply changes
terraform apply
```

---

## 🛡️ Key Capabilities

| Domain | Feature | Description |
| :--- | :--- | :--- |
| **Security** | **Zero-Trust Networking** | Default-Deny ingress rules enforced globally. |
| | **Secret Management** | Database passwords fetched dynamically from GCP Secret Manager. |
| | **Non-Destructive IAM** | IAM managed via `_member` resources to coexist with manual grants. |
| **Cost** | **Spot Instances** | Native support for Spot VMs (`is_spot = true`) for non-prod workloads. |
| | **Scheduling** | Automated start/stop schedules for development resources. |
| **Observability** | **Centralized Logging** | Automated Log Sinks export to BigQuery/Storage. |
| | **Monitoring** | Pre-provisioned Dashboards and Alert Policies. |

---

## ⚙️ Operational Governance

### Handling Manual Changes ("Drift")
Infrastructure drift occurs when resources are modified manually in the Cloud Console, causing a divergence from the Terraform state.

#### Scenario 1: Legitimate Changes (Codify)
If a manual change (e.g., a hotfix firewall rule) needs to be permanent:
1.  Identify the change via `terraform plan`.
2.  Update the corresponding `.auto.tfvars` file (e.g., add to `custom_firewall_rules`).
3.  Run `terraform plan` to verify the code now matches the infrastructure.

#### Scenario 2: Unauthorized Changes (Remediate)
If a change was accidental or unauthorized:
1.  Run `terraform apply`.
2.  Terraform will revert the resource to its defined state (e.g., removing unauthorized firewall rules).

---

## 📂 Repository Structure

```plaintext
├── modules/
│   ├── composition/          # Architectural Blueprints
│   ├── global/               # Global Resources (IAM, VPC)
│   └── regional/             # Regional Resources (GKE, SQL)
├── environments/
│   ├── dev/                  # Development Environment
│   ├── staging/              # Staging Environment
│   └── prod/                 # Production Environment
├── backend-configs/          # Terraform State Backend Configurations
└── scripts/                  # Automation Scripts
```
