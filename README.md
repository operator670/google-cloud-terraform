# Google Cloud Platform Infrastructure

This repository contains the Terraform codebase for managing the Multi-Customer Google Cloud Platform (GCP) infrastructure. It is designed using the **Layered Composition Architecture** to ensure consistency, scalability, and strict governance across Development, Staging, and Production environments.

## 🏗️ Architecture

The infrastructure adopts a **Layered Composition Architecture** (Evolved from the Unified Blueprint) to maximize code reuse while providing strong isolation between shared infrastructure and individual projects.

### 1. Shared Infrastructure Layer (`environments/*/infrastructure`)

The foundational layer for each environment. It manages shared resources that provide common services to multiple projects:

- **Networking**: VPCs, Subnets, Cloud NAT.
- **Connectivity**: Network Connectivity Center (NCC) Hubs and spokes.
- **Compliance**: Organization-level firewall policies and governance.

### 2. Project Layer (`environments/*/projects/*`)

Independent projects that consume the shared infrastructure. Each project has its own lifecycle and state file, reducing blast radius and enabling independent deployments.

- **Workloads**: Compute Engine, GKE, Cloud Run.
- **Data**: Cloud SQL, Cloud Storage.
- **Security**: Project-specific secrets and IAM.

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

### 2. Landing Zone Deployment (Organization Level)

The Landing Zone establishes the core resource hierarchy (folders) and central projects (Networking, Security).

```bash
# 1. Navigate to landing zone
cd environments/landing-zone

# 2. Configure variables
# Edit terraform.auto.tfvars with your org_id and billing_account

# 3. Define Hierarchy
# Edit landing-zone.yaml to define your folders and projects

# 4. Deploy
terraform init
terraform apply
```

### 3. Environment & Workload Setup (Project Level)

After the landing zone is established, you can deploy environment-specific infrastructure and workloads. We use **Integrated Backend Configuration** in `providers.tf` to simplify usage and enforce state isolation.

#### Shared Infrastructure Layer

```bash
cd environments/dev/infrastructure
terraform init
```

#### Project Workload Layer

```bash
cd environments/dev/projects/service-project
terraform init
```

### 4. Making Changes (The `.auto.tfvars` Workflow)

We use split configuration files. **You do not edit `main.tf`**. You only edit data files.

| I want to... | Edit this file |
| :--- | :--- |
| **Add a Virtual Machine** | `compute.auto.tfvars` |
| **Open a Custom Port** | `firewall.auto.tfvars` (Add to `firewall_policies`) |
| **Add a Database** | `database.auto.tfvars` |
| **Change GKE Node Count** | `gke.auto.tfvars` |
| **Add a Bucket** | `storage.auto.tfvars` |

### 5. Deploying

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

### 1. State File Decentralization (Layered Isolation)

By splitting shared infrastructure from project workloads, we ensure that a mistake in a project deployment cannot accidentally delete the networking backbone.

### 2. Hard Locks (VPCs)

The **Networking** module uses `prevent_destroy = true`. This is a hard lock at the provider level. To delete a VPC, you must manually unlock the module code (`modules/global/networking/main.tf`).

### 3. Guardrails (Compute & Databases)

Resources like VMs and SQL Instances have `deletion_protection = true` by default.

---

## 📖 Documentation Hub

For a deeper dive into the architectural decisions and technical governance of this project, see:

- [Architecture Overview](file:///home/sarthak/terraform-codebase/docs/architecture-overview.md): The "Layered Composition" explained.
- [Comparison of Approaches](file:///home/sarthak/terraform-codebase/docs/comparison-of-approaches.md): Unified vs. Layered vs. Service Silos.
- [Blast Radius Management](file:///home/sarthak/terraform-codebase/docs/blast-radius-management.md): How we stay safe in a layered model.
- [Project Deletion Guide](file:///home/sarthak/terraform-codebase/docs/project-deletion-guide.md): Safe workflow for removing projects and handling `deletion_policy`.
- [Target Customer Profiles](file:///home/sarthak/terraform-codebase/docs/target-customer-profiles.md): Who is this codebase built for?
- [Drift Detection Guide](file:///home/sarthak/terraform-codebase/docs/drift-detection.md): How to detect, analyze, and resolve infrastructure drift.

---

## 📂 Repository Structure

```plaintext
├── modules/
│   ├── composition/          # The Golden Blueprints
│   ├── global/               
│   └── regional/             
├── environments/
│   ├── dev/                  
│   │   ├── infrastructure/   # Shared Networking/NCC
│   │   └── projects/         # Individual Project States
│   ├── staging/              
│   └── prod/                 
├── backend-configs/          # State Bucket Configs
└── scripts/                  
```
