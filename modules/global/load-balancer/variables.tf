variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "name" {
  description = "Name of the load balancer"
  type        = string
}

variable "ssl_enabled" {
  description = "Enable SSL/HTTPS"
  type        = bool
  default     = false
}

variable "ssl_certificates" {
  description = "List of SSL certificate domains (for Google-managed certs)"
  type        = list(string)
  default     = []
}

variable "ssl_certificate_ids" {
  description = "List of existing SSL certificate IDs"
  type        = list(string)
  default     = []
}

variable "use_ssl_policy" {
  description = "Use SSL policy"
  type        = bool
  default     = false
}

variable "ssl_policy" {
  description = "SSL policy name"
  type        = string
  default     = null
}

variable "backends" {
  description = "List of backend service configurations"
  type = list(object({
    name                = string
    protocol            = string
    port                = number
    port_name           = string
    timeout_sec         = optional(number, 30)
    enable_cdn          = optional(bool, false)
    session_affinity    = optional(string, "NONE")
    affinity_cookie_ttl = optional(number, 0)
    instance_groups     = list(string)
    health_check = optional(object({
      check_interval_sec  = optional(number, 10)
      timeout_sec         = optional(number, 5)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 3)
      request_path        = optional(string, "/")
      port                = optional(number, 80)
    }), {})
  }))
}

variable "url_map_host_rules" {
  description = "Custom URL map host rules"
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  default = []
}

variable "create_ipv6_address" {
  description = "Create IPv6 address"
  type        = bool
  default     = false
}

variable "enable_http_to_https_redirect" {
  description = "Enable HTTP to HTTPS redirect"
  type        = bool
  default     = false
}

variable "firewall_source_ranges" {
  description = "Source IP ranges for firewall rule (default: Google LB ranges)"
  type        = list(string)
  default     = ["35.191.0.0/16", "130.211.0.0/22"]
}

# CDN Configuration
variable "enable_cdn" {
  description = "Enable Cloud CDN on backend services"
  type        = bool
  default     = false
}

variable "cdn_policy" {
  description = "Cloud CDN policy configuration"
  type = object({
    cache_mode                   = optional(string, "CACHE_ALL_STATIC")
    default_ttl                  = optional(number, 3600)
    max_ttl                      = optional(number, 86400)
    client_ttl                   = optional(number, 3600)
    negative_caching             = optional(bool, false)
    serve_while_stale            = optional(number, 0)
    signed_url_cache_max_age_sec = optional(number, 0)
    cache_key_policy = optional(object({
      include_host           = optional(bool, true)
      include_protocol       = optional(bool, true)
      include_query_string   = optional(bool, true)
      query_string_whitelist = optional(list(string), [])
      query_string_blacklist = optional(list(string), [])
    }), null)
  })
  default = null
}

# Cloud Armor
variable "enable_cloud_armor" {
  description = "Enable Cloud Armor security policy"
  type        = bool
  default     = false
}

variable "cloud_armor_policy" {
  description = "Cloud Armor security policy self link"
  type        = string
  default     = null
}
