# Target Customer Profiles

The Composition Blueprint architecture is not for everyone, but for certain types of customers, it is a "force multiplier."

## 1. Managed Service Providers (MSPs)

**Why:** MSPs often manage 10 or 20 different customers with similar requirements. By using a Blueprint, an MSP can stamp out a new, secure environment for a new client in minutes rather than days.

## 2. High-Growth Startups / Scale-ups

**Why:** These companies often have a small Platform Team supporting a large dev group. The Blueprint allows the Platform Team to set the "gold standard" for security (Tiered Firewalls, NCC Hubs) while letting developers self-serve VMs and Buckets safely via `.tfvars`.

## 3. SaaS Platforms (Multi-Environment)

**Why:** Reliability is key. Any drift between the developer's environment and the production environment is a major risk. The Blueprint ensures that the network plumbing is identical at every stage of the pipeline.

---

## 🚩 When to avoid this method

- **Legacy Monoliths**: Where parts of the infrastructure change once every 5 years and others change every 5 minutes.
- **Hard Org Silos**: If the Networking team and the App team are in different countries and refuse to share a repository, "Component Silos" are a political necessity.
