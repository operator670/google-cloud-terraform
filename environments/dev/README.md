# Development Environment

This environment uses a **Project-Centric Layered Architecture** to manage shared infrastructure and individual project workloads at scale.

## Layered Structure

### 1. [Infrastructure Layer](file://terraform-codebase/environments/dev/infrastructure/)

Handles shared resources used by all projects:

- **Networking**: Shared VPCs, subnets, and Cloud NAT.
- **Connectivity**: Network Connectivity Center (NCC) hubs.

### 2. [Projects Layer](file://terraform-codebase/environments/dev/projects/)

Contains individual workload folders for different applications or teams.

## Critical Standards

### 1. State Isolation

Each directory (Infrastructure or Project) has its own **isolated state** in GCS.

- **Networking**: `prefix = "dev/infrastructure"`
- **Projects**: `prefix = "dev/projects/PROJECT_NAME"`

### 2. Shared VPC Integration

Workload projects should be configured as Shared VPC Service Projects:

- Set `is_shared_vpc_service = true` in `main.tf`.
- Set `host_project_id` to the Networking project ID.
- Configure `compute_instances` with the host's `network_project`, `network_key`, and `subnet_name`.

## Usage

1. **Initialize**: Run `terraform init` (Backend is pre-configured in `providers.tf`).
2. **Apply Infrastructure**: Always apply `environments/dev/infrastructure` before any projects.
3. **New Project**: Copy `projects/project-template/` to a new folder and update `providers.tf` (Prefix) and `common.auto.tfvars`.

## Standards

- Architecture logic is centralized in `modules/composition/environment`.
- All projects MUST use the integrated backend configuration to prevent state collisions.
