# Infrastructure Drift Detection & Remediation

As infrastructure evolves, "drift" occurs when the actual state of your resources in Google Cloud diverges from your Terraform configuration. This guide outlines how to detect, analyze, and resolve drift in this repository.

## 1. Detecting Drift

The primary mechanism for detecting drift is the `terraform plan` command.

```bash
terraform plan
```

- **No Changes**: Infrastructure is in sync.
- **Changes Detected**:
  - **Update in-place (~)**: A property has changed (e.g., someone added a tag manually). Terraform will revert it.
  - **Destroy and Add (-/+)**: A critical immutable property changed. Terraform will recreate the resource.
  - **Create (+)**: Terraform tracks a resource that doesn't exist in the state (or you added code for a new one).

## 2. Handling Unmanaged Resources (The "Import" Workflow)

If you find a resource in GCP that *should* be managed by Terraform but isn't (e.g., a manually created VM), follow this workflow:

### Step 1: Create an Import Block

Create a temporary `import.tf` file to tell Terraform which resource to target.

```hcl
import {
  id = "projects/PROJECT_ID/zones/ZONE/instances/INSTANCE_NAME"
  to = module.project_workload.module.compute_instances["INSTANCE_NAME"].google_compute_instance.main[0]
}
```

### Step 2: Generate Configuration

Run Terraform to generate the HCL code for you.

```bash
terraform plan -generate-config-out=generated_resource.tf
```

### Step 3: Automate the Integration (Recommended)

Use the helper script `generate-tfvars.py` (if available in your project) to automatically parse the generated config and format it for your `.auto.tfvars` file.

1. Update `import.tf`.
2. Run `python3 generate-tfvars.py`.
3. Copy the output to `compute.auto.tfvars`.

## 3. Handling IAM Drift

IAM is a common source of drift.

- **Authoritative (`google_project_iam_binding`)**: Terraform is the *only* source of truth. Any manual role grants are removed.
- **Non-Authoritative (`google_project_iam_member`)**: Terraform manages *its* specific grants but ignores others.

**Strategy in this Repo**: We generally use **Non-Authoritative** bindings for project-level access to allow coexistense with manual operational grants. However, for critical security groups, we may enforce authoritative bindings.

## 4. Best Practices

1. **Run Plans Daily**: Frequent checks prevent massive drift accumulation.
2. **Tag Everything**: Use `managed_by = terraform` labels to visually identify managed resources in the console.
3. **Review "Destroy" Actions Carefully**: Always verify *why* a resource is being replaced. It might be due to a harmless-looking change (basic vs premium network tier).
