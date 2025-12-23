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

- **Global**: Networking (VPC, Firewall, NAT), IAM, Secret Manager.
- **Regional**: Compute Engine, GKE, Cloud SQL, Cloud Storage.

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
| **Open a Custom Port** | `firewall.auto.tfvars` (Add to `firewall_policies`) |
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
| **Networking** | **Enterprise Transit Hub** | Uses **Network Connectivity Center (NCC)** to connect multiple VPCs with tiered isolation. |
| | **Zero-Trust Networking** | Default-Deny ingress rules enforced globally. |
| **Security** | **Secret Management** | Database passwords fetched dynamically from GCP Secret Manager. |
| | **Non-Destructive IAM** | IAM managed via `_member` resources to coexist with manual grants. |
| **Cost** | **Spot Instances** | Native support for Spot VMs (`is_spot = true`) for non-prod workloads. |
| | **Scheduling** | Automated start/stop schedules for development resources. |
| **Observability** | **Centralized Logging** | Automated Log Sinks export to BigQuery/Storage. |
| | **Monitoring** | Pre-provisioned Dashboards and Alert Policies. |

---

## 🔒 Infrastructure Seatbelts (Blast Radius Reduction)

To prevent accidental data loss or network outages, we implement the following safety mechanisms:

### 1. Hard Locks (VPCs)

The **Networking** module uses `prevent_destroy = true`. This is a hard lock at the provider level. To delete a VPC, you must manually unlock the module code (`modules/global/networking/main.tf`).

### 2. Guardrails (Compute & Databases)

Resources like VMs and SQL Instances have `deletion_protection = true` by default.

- **To delete a specific resource**: Set `deletion_protection = false` in your `.auto.tfvars` file, run `apply` once to unlock it, and then you can safely remove the resource.

---

## ⚙️ Operational Governance

### Handling Manual Changes ("Drift")

Infrastructure drift occurs when resources are modified manually in the Cloud Console, causing a divergence from the Terraform state.

#### Scenario 1: Legitimate Changes (Codify)

If a manual change (e.g., a hotfix firewall rule) needs to be permanent:

1. **Identify**: Run `terraform plan` to see what Terraform wants to undo.
2. **Codify**: Update the corresponding `.auto.tfvars` file (e.g., add to `firewall_policies`) to match the console reality.
3. **Verify**: Run `terraform plan` again. It should say "No changes".

#### Scenario 2: Unauthorized Changes (Remediate)

If a change was accidental or unauthorized:

1. **Run Apply**: `terraform apply`.
2. **Result**: Terraform will strictly revert the resource to its defined state (e.g., closing an unauthorized port).

---

---

## 📖 Documentation Hub

For a deeper dive into the architectural decisions and technical governance of this project, see:

- [Architecture Overview](file:///home/sarthak/terraform-codebase/docs/architecture-overview.md): The "Composition Blueprint" explained.
- [Comparison of Approaches](file:///home/sarthak/terraform-codebase/docs/comparison-of-approaches.md): Blueprint vs. Service Silos.
- [Blast Radius Management](file:///home/sarthak/terraform-codebase/docs/blast-radius-management.md): How we stay safe in a unified state.
- [Target Customer Profiles](file:///home/sarthak/terraform-codebase/docs/target-customer-profiles.md): Who is this codebase built for?

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
├── backend-configs/          # State Bucket Configs
└── scripts/                  
```
