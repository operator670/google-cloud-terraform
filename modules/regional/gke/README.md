# Regional GKE (Kubernetes) Module

This module creates Google Kubernetes Engine (GKE) clusters with node pools, autoscaling, and Workload Identity.

## Features

- GKE Standard or Autopilot clusters
- Multiple node pools with autoscaling
- Workload Identity for secure authentication
- Private clusters with authorized networks
- Network policy support
- Binary authorization
- Release channels (rapid, regular, stable)

## Usage

```hcl
module "gke" {
  source = "../../modules/regional/gke"
  
  project_id = var.project_id
  region     = "asia-south1"
  
  cluster_name = "my-gke-cluster"
  
  network    = module.networking.network_name
  subnetwork = module.networking.subnet_names["subnet-asia-south1"]
  
  # IP ranges for pods and services
  pods_ip_range_name     = "gke-pods"
  services_ip_range_name = "gke-services"
  
  # Node pools
  node_pools = [
    {
      name         = "default-pool"
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 5
      disk_size_gb = 100
    }
  ]
  
  # Enable Workload Identity
  workload_identity = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| region | GCP Region | string | - | yes |
| cluster_name | Name of GKE cluster | string | - | yes |
| network | VPC network name | string | - | yes |
| subnetwork | Subnet name | string | - | yes |
| node_pools | List of node pools | list(object) | [] | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | Cluster ID |
| cluster_endpoint | Cluster endpoint |
| cluster_ca_certificate | Cluster CA certificate |
