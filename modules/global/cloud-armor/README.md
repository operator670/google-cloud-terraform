# Global Cloud Armor Module

This module creates Cloud Armor security policies for protecting applications at the Google Cloud edge.

## Features

- Security policies with custom rules
- Pre-configured WAF rules (OWASP Top 10)
- Rate limiting and throttling
- Geo-based access control
- Bot management
- Integration with load balancers

## Usage

```hcl
module "cloud_armor" {
  source = "../../modules/global/cloud-armor"
  
  project_id  = var.project_id
  policy_name = "my-security-policy"
  
  # Default rule action
  default_rule_action = "allow"
  
  # Custom security rules
  security_rules = [
    {
      priority    = 1000
      action      = "deny(403)"
      description = "Block traffic from specific countries"
      match = {
        expr = "origin.region_code in ['CN', 'RU']"
      }
    },
    {
      priority    = 2000
      action      = "rate_based_ban"
      description = "Rate limit per IP"
      rate_limit_options = {
        conform_action = "allow"
        exceed_action  = "deny(429)"
        rate_limit_threshold = {
          count        = 100
          interval_sec = 60
        }
      }
      match = {
        versioned_expr = "SRC_IPS_V1"
        config = {
          src_ip_ranges = ["*"]
        }
      }
    }
  ]
  
  # Pre-configured WAF rules
  preconfigured_waf_rules = [
    {
      priority = 100
      action   = "deny(403)"
      rule_ids = [
        "owasp-crs-v030001-id942251-sqli",
        "owasp-crs-v030001-id941150-xss"
      ]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| policy_name | Name of the security policy | string | - | yes |
| default_rule_action | Default action (allow/deny) | string | allow | no |
| security_rules | List of custom security rules | list(object) | [] | no |
| preconfigured_waf_rules | Pre-configured WAF rules | list(object) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| policy_id | Cloud Armor policy ID |
| policy_self_link | Policy self link |
