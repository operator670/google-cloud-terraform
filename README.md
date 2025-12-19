# Google Cloud Platform Infrastructure

This repository contains the Terraform codebase for managing the Multi-Customer Google Cloud Platform (GCP) infrastructure. It is designed using the **Composition Module Pattern** to ensure consistency, scalability, and strict governance across Development, Staging, and Production environments.

## 🏗️ Architecture

The infrastructure adopts a **Unified Blueprint Architecture** to maximize code reuse and eliminate configuration drift.

### 1. Composition Blueprint (`modules/composition`)
The core architectural logic is centralized in the `modules/composition/environment` module. This "Blueprint" defines the standard reference architecture (VPC, Compute, GKE, Databases, IAM) that is instantiated across all environments.

### 2. Environment Configurations (`environments/*`)
Environments are purposefully lightweight. They consume the **Composition Blueprint** and apply environment-specific configurations via variables (e.g., machine types, cluster sizes, high-availability settings).

### 3. Service Modules (`modules/{global,regional}`)
Granular, reusable modules for individual GCP services:
-   **Global**: Networking (VPC, Firewall, NAT), IAM, Secret Manager.
-   **Regional**: Compute Engine, GKE, Cloud SQL, Cloud Storage.

---

## 👩‍💻 Developer Workflow

### 1. Prerequisites
Ensure you have the following tools installed and authenticated:
```bash
# Authenticate gcloud
gcloud auth application-default login

# Authenticate specific project
gcloud config set project YOUR-PROJECT-ID
```

### 2. Initial Setup
We use **Partial Backend Configuration** to keep sensitive bucket names out of the code.

```bash
# 1. Create your backend config file from template
cp backend-configs/dev.tfvars.template backend-configs/dev.tfvars

# 2. Edit the file to set your Terraform State Bucket
# bucket = "my-company-terraform-state"

# 3. Initialize the environment
cd environments/dev
terraform init -backend-config=../../backend-configs/dev.tfvars
```

### 3. Making Changes (The `.auto.tfvars` Workflow)
We use split configuration files. **You do not edit `main.tf`**. You only edit data files.

| I want to... | Edit this file |
| :--- | :--- |
| **Add a Virtual Machine** | `compute.auto.tfvars` |
| **Open a Custom Port** | `firewall.auto.tfvars` (Add to `custom_firewall_rules`) |
| **Add a Database** | `database.auto.tfvars` |
| **Change GKE Node Count** | `gke.auto.tfvars` |
| **Add a Bucket** | `storage.auto.tfvars` |

### 4. Deploying
Always preview your changes before applying.

```bash
# 1. Preview changes (Auto-detects all your .tfvars changes)
terraform plan

# 2. Deploy
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
1.  **Identify**: Run `terraform plan` to see what Terraform wants to undo.
2.  **Codify**: Update the corresponding `.auto.tfvars` file (e.g., add to `custom_firewall_rules`) to match the console reality.
3.  **Verify**: Run `terraform plan` again. It should say "No changes".

#### Scenario 2: Unauthorized Changes (Remediate)
If a change was accidental or unauthorized:
1.  **Run Apply**: `terraform apply`.
2.  **Result**: Terraform will strictly revert the resource to its defined state (e.g., closing an unauthorized port).

---

## 📂 Repository Structure

```plaintext
├── modules/
│   ├── composition/          # The Golden Blueprint
│   ├── global/               
│   └── regional/             
├── environments/
│   ├── dev/                  # <--- You work here
│   ├── staging/              
│   └── prod/                 
├── backend-configs/          # State Bucket Configs (Not in Git)
└── scripts/                  
```
