# Networking Variables
variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
  default     = "10.0.0.0/24"
}

variable "enable_nat" {
  description = "Enable Cloud NAT"
  type        = bool
  default     = true
}

variable "custom_firewall_rules" {
  description = "List of custom firewall rules"
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
