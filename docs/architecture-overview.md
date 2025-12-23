# Architecture Overview: The Composition Blueprint

## 🏛️ The Core Concept

The "Composition Blueprint" is a design pattern where the entire infrastructure lifecycle is managed through a single, standardized reference architecture (the **Blueprint**).

Instead of writing separate Terraform code for every environment, we define exactly **HOW** a standard environment should look in a central module (`modules/composition/environment`), and we use environment-specific folders (`environments/dev`, `environments/prod`) to define **WHAT** resources should exist.

## 🔑 Key Components

### 1. The Service Modules (Building Blocks)

Granular modules (Networking, GKE, SQL) that do one thing well. They contain the low-level HCL code and follow Google Cloud best practices.

### 2. The Composition (The Glue)

This is the `main.tf` inside `modules/composition/environment`. It "glues" the service modules together. It knows, for example, that a VM needs a Subnet ID and a Service Account. It handles these dependencies automatically so the end-user doesn't have to.

### 3. The Environment Layer (The UI)

This layer consists of `.tfvars` files. It acts as the "User Interface" for the infrastructure. Developers or Platform Engineers simply provide a list of names, CIDR ranges, and machine types.

## 🌟 Why This Model?

1. **Elimination of Drift**: Since Dev and Prod use the exact same logic, you never run into "It works in Dev but not in Prod" networking issues.
2. **Atomic Orchestration**: You can build a complex, interconnected 7-tier network with NCC Hubs, instances, and databases in a single `terraform apply`.
3. **Governance at Scale**: Security policies (like our Tiered Firewalls) are written once in the Blueprint and enforced across 100% of the VPCs automatically.
