variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "customer_name" {
  description = "Customer name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "primary_region" {
  description = "Primary GCP region"
  type        = string
  default     = "asia-south1"
}

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_ncc" {
  description = "Enable Network Connectivity Center (NCC)"
  type        = bool
  default     = false
}

variable "ncc_hub_name" {
  description = "Name of the NCC Hub"
  type        = string
  default     = "enterprise-transit-hub"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = null
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
  default     = null
}

variable "enable_nat" {
  description = "Enable Cloud NAT"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    subnet_name           = string
    subnet_ip             = string
    subnet_region         = string
    subnet_private_access = optional(bool, true)
    subnet_flow_logs      = optional(bool, false)
    description           = optional(string, "")
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = []
}

variable "networks" {
  description = "Map of VPC networks to create"
  type = map(object({
    network_name            = optional(string, null)
    auto_create_subnetworks = optional(bool, false)
    routing_mode            = optional(string, "GLOBAL")
    exclude_from_ncc        = optional(bool, false)
    subnets = list(object({
      subnet_name           = string
      subnet_ip             = string
      subnet_region         = string
      subnet_private_access = optional(bool, true)
      subnet_flow_logs      = optional(bool, false)
      description           = optional(string, "")
      secondary_ranges = optional(list(object({
        range_name    = string
        ip_cidr_range = string
      })), [])
    }))
    enable_nat = optional(bool, false)
  }))
  default = {}
}

variable "firewall_policies" {
  description = "Map of firewall policies to create"
  type = map(object({
    network_key = string
    rules = list(object({
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
  }))
  default = {}
}
