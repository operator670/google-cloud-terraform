# Project Deletion Guide

This guide explains how to safely delete projects from the Terraform configuration. By default, projects are protected by a `deletion_policy = "PREVENT"` to avoid accidental data loss.

## ⚠️ Important Note

Project deletion is irreversible. Ensure you have backed up any critical data before proceeding.

---

## Standard Deletion Process

To delete a project, you must follow a two-phase "Permit then Remove" workflow.

### Phase 1: Permit Deletion in State

You must first tell Google Cloud that it is okay to delete the project by updating the policy in the Terraform state.

1. Locate the project in `landing-zone.yaml`.
2. Add `deletion_policy: DELETE` to the project configuration:

   ```yaml
   my-project:
     folder: "My-Folder"
     deletion_policy: DELETE  # <--- Permit deletion
     labels:
       env: "prod"
   ```

3. Run `terraform apply`. This updates the existing project's metadata without destroying it yet.

### Phase 2: Remove from Configuration

Once the state is updated with the `DELETE` policy:

1. Remove the project block from `landing-zone.yaml`.
2. Run `terraform apply`.
3. Terraform will now successfully destroy the project.

---

## Troubleshooting: "Cannot destroy project..."

If you see an error stating `Cannot destroy project as deletion_policy is set to PREVENT`, it usually means Terraform is trying to **replace** the project (Destroy + Create) instead of updating it in-place.

### Solution: Untaint the Project

If the project is marked as "tainted," Terraform will always try to destroy it first. You must "untaint" it to allow an in-place update of the policy.

1. Identify the tainted resource from the error message (e.g., `module.landing_zone.module.service_projects["my-project"].google_project.main`).
2. Run the untaint command:

   ```bash
   terraform untaint 'module.landing_zone.module.service_projects["my-project"].google_project.main'
   ```

3. Run `terraform apply` again. It will now perform an "in-place update" to change the policy to `DELETE`.
4. Proceed to **Phase 2** (Remove from Configuration).

### Troubleshooting: "Cloud billing quota exceeded"

If you see this error, it means Terraform is trying to **replace** projects (Destroy then Create). For a brief moment, you would have more projects than your billing account allows.

**Solution:**
Follow the **Untaint the Project** steps above. By untainting, you force Terraform to only *update* the existing projects in-place, which does not count against your new project quota.

### Troubleshooting: "Error acquiring the state lock"

This happens if a previous Terraform command was interrupted (e.g., a crash or manual cancellation), leaving a lock on the state file to prevent corruption.

**Solution:**

1. Identify the **Lock ID** from the error message (e.g., `1767800732249101`).
2. Run the force-unlock command:

   ```bash
   terraform force-unlock <LOCK_ID>
   ```

3. Once unlocked, you can resume your `plan` or `apply`.

### Troubleshooting: "Cloud billing quota exceeded" (Again)

If you still see quota errors even after untainting, it means your billing account quota is so low that even modifying an existing project is being blocked.

**Solution: Detach Billing Entirely**
You can remove the billing attachment from the projects to bypass these checks.

1. In `environments/landing-zone/main.tf`, ensure the `billing_account` line is removed or commented out in the `module "landing_zone"` call.
2. Run `terraform apply`. This will detach the projects from the billing account in the state.
3. Once detached, you can safely remove the projects from the config and apply again.
