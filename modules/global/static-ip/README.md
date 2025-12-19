# Global Static IP Module

This module manages static IP addresses for Google Cloud Platform, supporting both global and regional IP addresses.

## Features

- Global static IP addresses (for global load balancers)
- Regional static IP addresses (for regional resources)
- IPv4 and IPv6 support
- IP address reservation and lifecycle management
- Labels for organization

## Usage

### Global Static IP

```hcl
module "global_ip" {
  source = "../../modules/global/static-ip"
  
  project_id = var.project_id
  
  global_ips = [
    {
      name        = "lb-global-ip"
      description = "IP for global load balancer"
    },
    {
      name        = "lb-global-ipv6"
      description = "IPv6 for global load balancer"
      ip_version  = "IPV6"
    }
  ]
}
```

### Regional Static IP

```hcl
module "regional_ip" {
  source = "../../modules/global/static-ip"
  
  project_id = var.project_id
  
  regional_ips = [
    {
      name        = "nat-ip-asia-south1"
      region      = "asia-south1"
      description = "IP for Cloud NAT"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| global_ips | List of global IP addresses | list(object) | [] | no |
| regional_ips | List of regional IP addresses | list(object) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| global_ip_addresses | Map of global IP names to addresses |
| regional_ip_addresses | Map of regional IP names to addresses |
