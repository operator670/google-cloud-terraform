# Landing Zone Setup Guide

This directory contains the Terraform configuration for a scalable, data-driven Landing Zone. It is designed to manage hundreds of Google Cloud projects efficiently using a YAML-based configuration.

## 🚀 How to Setup

Follow these steps to initialize and deploy your landing zone:

1. **Configure Folders and Projects**:
    Modify the [landing-zone.yaml](file://terraform-codebase/environments/landing-zone/landing-zone.yaml) file to define your folder hierarchy and project list.

2. **Set Required Variables**:
    Create a `terraform.auto.tfvars` file (or use an existing one) and provide the following:

    ```hcl
    parent_id       = "organizations/123456789" # or folders/123456789
    billing_account = "012345-6789AB-CDEF01"
    prefix          = "tws"
    env_name        = "lz"
    ```

3. **Initialize and Deploy**:

    ```bash
    terraform init
    terraform apply
    ```

## 🌐 Automated Shared VPC Logic

The Landing Zone automatically orchestrates networking relationships based on your YAML definitions:

- **Host Projects**: Set `is_shared_vpc_host: true`. The landing zone will enable the host project and prepare it to accept service projects.
- **Service Projects**: Set `shared_vpc_host: "PROJECT_KEY"`. The landing zone will:
    1. Attach the service project to the specified host.
    2. Enable the required Compute Engine APIs.
    3. (In workloads) Automatically grant the `Compute Network User` role to service accounts for cross-project resource provisioning.

---

---

## 💳 Billing Management

### Attaching Billing

The landing zone supports a tiered billing hierarchy, allowing for global defaults, specific overrides, and explicit opt-outs.

#### 1. Global Default

Set the `billing_account` variable in your `terraform.auto.tfvars`. This ID will be applied to **every project** that doesn't specify its own.

```hcl
# terraform.auto.tfvars
billing_account = "012345-6789AB-CDEF01"
```

#### 2. Per-Project Override

To use a different billing ID for a specific project, add the `billing_account` key to its definition in `landing-zone.yaml`.

```yaml
projects:
  special-project:
    folder: "Backend"
    billing_account: "AAAAAA-BBBBBB-CCCCCC" # Overrides the global default
```

#### 3. Explicit Opt-Out (No Billing)

To explicitly prevent a billing account from being attached to a project—even if a global default is set—set the `billing_account` to `null` in `landing-zone.yaml`.

```yaml
projects:
  free-project:
    folder: "Backend"
    billing_account: null # Forcefully removes billing (ignores global default)
```

### Automatic API Enablement

The landing zone is "billing-aware". If a project has a billing ID (either via global variable or YAML override):

- The **Compute Engine API** is automatically enabled for Host and Service projects.
- **Shared VPC** features are automatically configured.

> [!WARNING]
> If a project does **not** have a billing account, Shared VPC and Compute features will be skipped automatically to prevent Terraform from failing (as these APIs require billing).

---

## 🛡️ Project Liens

### What is a Lien?

A project lien is a safety mechanism that prevents a project from being accidentally deleted. By default, this landing zone creates a lien on **every project**.

### Toggling Liens via YAML

You can now decide whether to enable a lien for a specific project directly in `landing-zone.yaml` using the `enable_lien` attribute.

```yaml
projects:
  prod-database:
    folder: "Data"
    enable_lien: true   # Enabled (default behavior)
  
  dev-temp-project:
    folder: "Backend"
    enable_lien: false  # Disabled for easier deletion
```

### Why do they cause issues during deletion?

If you attempt to delete a project while a lien is active, the operation will fail. With `enable_lien: false`, you can bypass this protection for non-critical projects.

---

## 🗑️ How to Delete a Project (Step-by-Step)

To successfully delete a project, you must navigate two layers of protection: **Terraform Safety** (`deletion_policy`) and **GCP Safety** (`enable_lien`).

### The Difference

| Feature | Level | What it does |
| :--- | :--- | :--- |
| **`deletion_policy`** | Terraform | Prevents `terraform destroy` from running. If set to `PREVENT`, Terraform will error before even trying to tell GCP to delete the project. |
| **`enable_lien`** | GCP | A physical lock on the project in the cloud. If enabled, GCP will reject any deletion request (from Terraform or the Console) until it is removed. |

### Which one should I use?

- **Use `enable_lien: true`** for production projects to prevent accidental deletion via the Console or UI.
- **Set BOTH to false/DELETE** when you are ready to permanently destroy a project.

---

### Step 1: Prepare for Deletion

In `landing-zone.yaml`, update the project you want to delete:

```yaml
projects:
  my-project:
    folder: "Backend"
    deletion_policy: DELETE # Allows Terraform to initiate deletion
    enable_lien: false     # Removes the GCP-level lock
```

Run `terraform apply`. This will remove the lien but keep the project.

### Step 2: Remove from Configuration

1. Open `landing-zone.yaml`.
2. Delete the project entry.
3. Run `terraform apply`.

> [!TIP]
> If you forgot to set `enable_lien: false` and Terraform is already failing, you can remove the lien manually using:
> `gcloud alpha resource-manager liens delete [LIEN_NAME]`
