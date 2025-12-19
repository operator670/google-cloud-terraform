# GKE Clusters (Multiple)
variable "gke_clusters" {
  description = "Map of GKE clusters to create"
  type = map(object({
    region                  = string
    pods_ip_range_name      = string
    services_ip_range_name  = string
    enable_private_cluster  = optional(bool, true)
    enable_private_nodes    = optional(bool, true)
    master_ipv4_cidr_block  = optional(string, "172.16.0.0/28")
    enable_autopilot        = optional(bool, false)
    node_pools              = list(object({
      name         = string
      machine_type = string
      min_count    = number
      max_count    = number
      disk_size_gb = optional(number, 100)
      disk_type    = optional(string, "pd-standard")
      preemptible  = optional(bool, false)
      spot         = optional(bool, false) # Added for P2 enhancement
      auto_repair  = optional(bool, true)
      auto_upgrade = optional(bool, true)
    }))
    workload_identity     = optional(bool, true)
    enable_network_policy = optional(bool, true)
    release_channel       = optional(string, "REGULAR")
    custom_labels         = optional(map(string), {})
    authorized_networks   = optional(list(object({ # Added for P2 enhancement
      cidr_block   = string
      display_name = string
    })), [])
  }))
  default = {}
}
