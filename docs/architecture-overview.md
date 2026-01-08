# Architecture Overview: Layered Composition

## 🏛️ The Core Concept

The "Layered Composition" is an evolution of the Blueprint pattern. While we still manage infrastructure through standardized reference architectures, we now decouple the lifecycle of **Shared Infrastructure** from individual **Workload Projects**.

### From Unified to Layered

In the original "Unified Blueprint" model, every resource in an environment shared a single state file. As projects scaled to hundreds of workloads, this created a massive blast radius and long deployment times.

The **Layered Composition** model solves this by splitting the environment into two distinct layers:

1. **Shared Infrastructure Layer**: Managed in `environments/*/infrastructure`. This handles the "plumbing" (VPC, NCC Hubs, Cloud NAT) that changes rarely but is critical for all projects.
2. **Project Layer**: Managed in `environments/*/projects/*`. Each project has its own folder and dedicated state file, containing only the resources (VMs, GKE, SQL) needed for that specific workload.

## 🔑 Key Components

### 1. The Service Modules (Building Blocks)

Granular modules (`modules/global/*`, `modules/regional/*`) that do one thing well. They contain the low-level HCL code and follow Google Cloud best practices.

### 2. The Shared Blueprint (The Foundation)

Managed via `modules/composition/environment` (when configured for base infrastructure). It sets up the VPCs, subnets, and transit connectivity that all projects will eventually consume.

### 3. The Project Blueprint (The Workload)

Also managed via `modules/composition/environment`, but with `networks = {}`. It focuses on deploying applications, databases, and secrets into the existing shared networks.

## 🌟 Why This Model?

1. **Reduced Blast Radius**: A mistake in a single project state can never accidentally delete the shared VPC.
2. **Scalability**: Independent state files mean that 10 developers can deploy 10 different projects simultaneously without state locking conflicts.
3. **Faster Deployments**: Terraform only needs to refresh a handful of resources for a project update, rather than thousands of resources for the entire environment.
4. **Governance at Scale**: Security policies are still defined once but can be enforced granularly at both the shared infrastructure and project levels.
