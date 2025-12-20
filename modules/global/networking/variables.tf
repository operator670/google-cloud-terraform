variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Auto create subnetworks"
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "Network routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "GLOBAL"
}

variable "description" {
  description = "Description of the VPC network"
  type        = string
  default     = ""
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


variable "routes" {
  description = "List of custom routes"
  type = list(object({
    name              = string
    description       = optional(string, "")
    dest_range        = string
    next_hop_internet = optional(bool, false)
    next_hop_ip       = optional(string, null)
    next_hop_instance = optional(string, null)
    next_hop_gateway  = optional(string, null)
    priority          = optional(number, 1000)
    tags              = optional(list(string), [])
  }))
  default = []
}

variable "enable_nat" {
  description = "Enable Cloud NAT"
  type        = bool
  default     = false
}

variable "nat_regions" {
  description = "List of regions to create Cloud NAT"
  type        = list(string)
  default     = []
}

variable "nat_ip_allocate_option" {
  description = "NAT IP allocation option (AUTO_ONLY or MANUAL_ONLY)"
  type        = string
  default     = "AUTO_ONLY"
}

variable "nat_log_config_enable" {
  description = "Enable NAT logging"
  type        = bool
  default     = false
}

variable "nat_log_config_filter" {
  description = "NAT log filter (ALL, ERRORS_ONLY, TRANSLATIONS_ONLY)"
  type        = string
  default     = "ALL"
}
