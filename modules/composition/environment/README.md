# Environment Composition Module (The Blueprint)

This module acts as the **Central Blueprint** for all infrastructure environments (Dev, Staging, Prod). It leverages the Composition Pattern to ensure that all environments follow a standardized architecture while allowing for controlled variability via input variables.

## Global Governance & Standardized Controls

The `main.tf` in this directory is the **Source of Truth** for global policies. It ensures that every environment (regardless of its specific settings) adheres to these standards:

- **Centrally Managed Firewalls**: The logic for applying firewall policies across *all* VPCs is defined here. This ensures that even "Sandbox" VPCs receive standard hardening rules unless explicitly exempted.
- **Mandatory NCC Integration**: The NCC Hub logic ensures that transitive routing is established consistently across the organization.
- **Structured Naming Conventions**: Resource naming (controlled via `locals.tf`) is enforced here to prevent naming collisions and ensure visibility across the GCP Console.
- **Automatic NAT Deployment**: Internet access for private subnets is standard across the blueprint.
- **Identity Isolation**: Service accounts for Compute and GKE are automatically created per-environment to enforce the Principle of Least Privilege.

## �🚀 Core Features

The infrastructure logic is centralized in this module's `main.tf`. Changes made here propagate to all environments consuming this blueprint.

### 1. Networking & Connectivity

- **Multi-VPC Management**: Orchestrates the creation of multiple VPC networks and their subnets.
- **Network Connectivity Center (NCC)**: Manages a central transit hub and registers VPCs as spokes for transitive routing.
- **Selective Isolation**: Supports the `exclude_from_ncc` flag to keep specific VPCs (e.g., Sandboxes) isolated from the main transit hub.
- **Cloud NAT**: Configures high-availability NAT gateways for private subnet internet access.

### 2. Tiered Security (Firewall)

- **Granular Policies**: Implements the `firewall_policies` structure to enforce tiered communication (`Web -> App -> Database`).
- **Default Hardening**: Includes optional default-deny logic for ingress traffic.

### 3. Compute & Orchestration

- **GCE Instances**: Manages Virtual Machines with support for custom naming, specific subnets, and disks.
- **GKE Clusters**: Multi-zonal Kubernetes clusters with managed node pools and specialized service account integration.

### 4. Data & Storage

- **Cloud SQL**: Automated provisioning of PostgreSQL/MySQL instances with private IP connectivity.
- **Cloud Storage**: Uniform bucket management with lifecycle policies and IAM bindings.

### 5. IAM & Secrets

- **Service Accounts**: Creates and manages least-privileged identities for Compute and GKE.
- **Secret Manager Integration**: Bootstraps secret references for sensitive data like database passwords.

### 6. Shared VPC Support (New)

- **Service Project Mode**: Use `is_shared_vpc_service = true` to skip local VPC creation in workload projects.
- **Automated IAM**: Automatically grants `roles/compute.networkUser` to the project's service accounts on the specified `host_project_id`.
- **Cross-Project Networking**: Simplifies linking compute instances and GKE clusters to a centrally managed host network.

## 🛠 Usage Architecture

- **`main.tf`**: Contains the resource logic and module calls (The "How").
- **`variables.tf`**: Defines the knobs and switches available to environments (The "What").
- **`locals.tf`**: Handles complex logic like naming conventions and attribute merging.

> [!IMPORTANT]
> To maintain structural integrity, always modify the logic in this directory rather than in individual environment folders.
