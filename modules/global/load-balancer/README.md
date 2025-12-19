# Global Load Balancer Module

This module creates global HTTP(S) load balancer resources including:
- Global forwarding rules
- Target HTTP(S) proxy
- URL maps
- Backend services
- Health checks
- SSL certificates (Google-managed or self-managed)

## Usage

```hcl
module "load_balancer" {
  source = "../../modules/global/load-balancer"
  
  project_id = var.project_id
  name       = "my-load-balancer"
  
  ssl_enabled = true
  ssl_certificates = ["example.com"]
  
  # Enable CDN
  enable_cdn = true
  cdn_policy = {
    cache_mode  = "CACHE_ALL_STATIC"
    default_ttl = 3600
    max_ttl     = 86400
    cache_key_policy = {
      include_protocol     = true
      include_host         = true
      include_query_string = false
    }
  }
  
  # Enable Cloud Armor
  enable_cloud_armor  = true
  cloud_armor_policy  = module.cloud_armor.policy_self_link
  
  backends = [
    {
      name        = "backend-1"
      protocol    = "HTTP"
      port        = 80
      port_name   = "http"
      timeout_sec = 30
      enable_cdn  = true
      instance_groups = [
        module.compute.instance_group_url
      ]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| name | Name of the load balancer | string | - | yes |
| ssl_enabled | Enable SSL | bool | false | no |
| backends | List of backend configurations | list(object) | [] | yes |

## Outputs

| Name | Description |
|------|-------------|
| external_ip | External IP address |
| url_map_id | URL map ID |
