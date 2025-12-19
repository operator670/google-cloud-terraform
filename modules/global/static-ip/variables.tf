variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "global_ips" {
  description = "List of global static IP addresses to create"
  type = list(object({
    name        = string
    description = optional(string, "")
    ip_version  = optional(string, "IPV4")
    labels      = optional(map(string), {})
  }))
  default = []
}

variable "regional_ips" {
  description = "List of regional static IP addresses to create"
  type = list(object({
    name        = string
    region      = string
    description = optional(string, "")
    ip_version  = optional(string, "IPV4")
    address_type = optional(string, "EXTERNAL")
    purpose     = optional(string, null)
    network_tier = optional(string, "PREMIUM")
    subnetwork  = optional(string, null)
    labels      = optional(map(string), {})
  }))
  default = []
}
