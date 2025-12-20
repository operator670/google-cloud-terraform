variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network to apply rules to"
  type        = string
}

variable "firewall_rules" {
  description = "List of firewall rules to create"
  type = list(object({
    name                    = string
    description             = optional(string, "")
    direction               = string
    priority                = optional(number, 1000)
    ranges                  = optional(list(string), [])
    source_tags             = optional(list(string), [])
    source_service_accounts = optional(list(string), [])
    target_tags             = optional(list(string), [])
    target_service_accounts = optional(list(string), [])
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = []
}

variable "enable_deny_all_ingress" {
  description = "Whether to create a default deny-all ingress rule"
  type        = bool
  default     = true
}
