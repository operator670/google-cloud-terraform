# Global Networking Module

This module creates global networking resources including:
- VPC networks (global resource)
- Subnets (regional, but managed in global networking)
- Firewall rules
- Cloud NAT and Cloud Router
- VPC Peering

## Usage

```hcl
module "networking" {
  source = "../../modules/global/networking"
  
  project_id   = var.project_id
  network_name = "my-vpc"
  
  subnets = [
    {
      subnet_name   = "subnet-asia-south1"
      subnet_ip     = "10.0.0.0/24"
      subnet_region = "asia-south1"
    }
  ]
  
  firewall_rules = [
    {
      name        = "allow-ssh"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["0.0.0.0/0"]
      target_tags = ["ssh"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| network_name | Name of the VPC network | string | - | yes |
| subnets | List of subnets | list(object) | [] | no |
| firewall_rules | List of firewall rules | list(object) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| network_name | VPC network name |
| network_self_link | VPC network self link |
| subnet_names | List of subnet names |
