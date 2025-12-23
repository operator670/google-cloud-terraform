# Blast Radius Management

One common concern with "Unified State" Blueprints is the Blast Radius—the potential impact of a single command. We manage this through a "Defense in Depth" strategy.

## 🛡️ The 3-Layer Safety System

### Layer 1: Provider-Level Hard Locks (`prevent_destroy`)

The most critical infrastructure (VPCs) is protected by Terraform's `prevent_destroy` flag.

- **Effect**: Even if you delete the code for a VPC and run `terraform apply`, the operation will fail and crash.
- **Surgical Intent**: You must manually edit the core module code to unlock a VPC for deletion.

### Layer 2: API-Level Guardrails (`deletion_protection`)

Resources that hold data (Cloud SQL) or represent significant cost (VMs) have the GCP `deletion_protection` flag enabled by default.

- **Effect**: The GCP API itself will refuse to delete the resource.
- **Workflow**: You must set `deletion_protection = false` in your `.auto.tfvars`, run an apply to "unlock" the cloud resource, and then you can proceed with the deletion.

### Layer 3: Logical Segregation (Environment Silos)

While services (Net/Compute/DB) are unified within an environment, the **Environments themselves stay isolated**.

- **Effect**: A mistake in `environments/dev` can NEVER touch `environments/prod`. Each environment has a different project, a different service account, and a different state file.

## 📈 Why this is safer than manual silos

In a "manual silo" model, humans often make copy-paste errors when trying to connect folders via `remote_state`. These errors are hard to debug and can lead to networking loops. In our model, **Terraform handles the connections**, reducing human error—the #1 cause of major outages.
