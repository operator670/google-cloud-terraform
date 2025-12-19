
# Multi-Customer GCP Terraform Infrastructure

A mature, enterprise-grade Terraform codebase implementation using the **Composition Module Pattern** to manage Google Cloud Platform infrastructure at scale.

## 🏗️ Technical Architecture (Level 3 Maturity)

This repository implements the industry-standard **Composition Pattern**:

### 1. The Blueprint (`modules/composition/environment`)
Instead of defining resources in each environment, we define the **entire architecture** once in a "Blueprint" module.
-   **Consolidated Logic**: Computes, DBs, GKE, Networking, IAM, and Secrets usage are orchestrated here.
-   **Single Source of Truth**: Changes to the architecture are made here and propagated to all environments.
-   **Drift-Proof**: `dev`, `staging`, and `prod` share the exact same structural code.

### 2. The Environments (`environments/*`)
Each environment is now extremely thin (just a `main.tf` calling the blueprint) and data-driven (`.tfvars`).
-   **dev**: Cost-optimized (Spot VMs, small DBs)
-   **staging**: Production-like parity
-   **prod**: High Availability, Protection Enabled

### 3. The Core Modules (`modules/{global,regional}`)
Primitive resources resource groups.
-   **Global**: Networking (VPC, Firewalls), IAM, Secret Manager
-   **Regional**: Compute, Database (Cloud SQL), GKE, Storage

---

## 🚀 Quick Start

### 1. Configure Backend (Partial Configuration)
We use `backend-configs` to separate sensitive state bucket names from code.

```bash
cd environments/dev
terraform init -backend-config=../../backend-configs/dev.tfvars
```

### 2. Configure Resources
We use split `.auto.tfvars` for clean organization.
-   Copy `compute.auto.tfvars.template` -> `compute.auto.tfvars`
-   Edit your instances, machine types, and flags.

### 3. Deploy
```bash
terraform plan   # Auto-loads all your .tfvars
terraform apply
```

---

## 🧱 Key Features (Audit Enhancements)

-   **🛡️ Security First**: Default-Deny Firewalls, Non-Destructive IAM, Private GKE Nodes.
-   **🔐 Secret Management**: Passwords fetch directly from Google Secret Manager (`password_secret_id`).
-   **💰 Cost Optimization**: Native support for Spot VMs (`is_spot = true`) and Schedule-based shutdowns.
-   **🔓 Flexibility**: Inject `custom_firewall_rules` per environment without changing code.

---

## ⚠️ Handling "Drift" (Manual Changes)

"Drift" is when someone manually changes a resource in the Google Cloud Console (e.g., opens a firewall port manually), making it different from the Terraform code.

### Scenario A: "I want to keep the manual change" (Codify it)
**Action**: You must update your Terraform code to match what you did in the console.
1.  **Identify**: Run `terraform plan`. It will say `~ update in-place` and show it wants to *undo* your manual change.
2.  **Update Code**: Edit your `.auto.tfvars` (e.g., add the new firewall rule to `custom_firewall_rules`).
3.  **Verify**: Run `terraform plan` again. It should now say `No changes`.

### Scenario B: "The manual change was a mistake/hack" (Revert it)
**Action**: Let Terraform overwrite the manual change.
1.  **Run Apply**: `terraform apply`.
2.  **Result**: Terraform will restore the infrastructure to exactly what is defined in the code (e.g., closing that manually opened port).

### Scenario C: "I deleted something manually"
1.  **DANGER**: If you delete a resource manually, Terraform will try to recreate it next time (which might fail if dependent IDs changed).
2.  **Fix**: Run `terraform apply` immediately to restore it, or remove it from code if meant to be deleted.

> **Pro Tip**: To prevent drift, use IAM conditions to remove "Editor" access for humans in Production, granting only "Viewer".

---

## 📂 Repository Structure

```
├── modules/
│   ├── composition/environment/  # <-- THE BLUEPRINT
│   ├── global/
│   └── regional/
├── environments/
│   ├── dev/                      # <-- Consumes Blueprint
│   ├── staging/
│   └── prod/
├── backend-configs/              # <-- State bucket configs
└── scripts/
```

>>>>>>> 0ab54ad (Initial Code added)
