# Comparison of Approaches: Architecture Models

When designing Terraform codebases, there are three primary models for organizing resources and state: **Unified Blueprint**, **Layered Composition**, and **Component Silos**.

## 1. Unified Blueprint (The Original Model)

*All services in an environment share a single state file.*

| Feature | Unified Blueprint |
| :--- | :--- |
| **Connectivity** | Native. Resources connect in memory. |
| **Consistency** | 100%. One logic for everything. |
| **Blast Radius** | High. One error can impact all services. |
| **Speed** | Slow. Large state files lead to long refresh times. |

**Best For:** Small environments or internal tools with limited resources.

---

## 2. Layered Composition (Our Current Standard)

*Shared infrastructure (Networking) and Projects (Workloads) have separate state files.*

| Feature | Layered Composition |
| :--- | :--- |
| **Connectivity** | Dynamic. Projects consume existing shared networks. |
| **Consistency** | 100%. Uses the same module library across layers. |
| **Blast Radius** | Low. Issues are isolated to specific projects. |
| **Speed** | Fast. Small, focused state files for projects. |

**Best For:** Scalable multi-tenant platforms, high-growth startups, and MSPs.

---

## 3. Component Silos (The Manual Approach)

*Each service (Net, IAM, DB) has its own independent state file.*

| Feature | Component Silos |
| :--- | :--- |
| **Connectivity** | Complex. Requires manual `remote_state` data sources. |
| **Consistency** | Low. Silos easily drift apart over time. |
| **Blast Radius** | Minimal. Maximum isolation. |
| **Speed** | Moderate. Multiple steps required for deployment. |

**Best For:** Very large organizations with completely independent engineering teams.

---

## ⚖️ Why We Chose Layered Composition

We found that while **Unified Blueprints** provided great consistency, they hit a "complexity wall" as we added more projects. **Layered Composition** is the hybrid solution: it maintains the **Global Consistency** of a blueprint while providing the **Isolation and Speed** of silos.
