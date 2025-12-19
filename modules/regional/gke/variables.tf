variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for the cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "description" {
  description = "Description of the cluster"
  type        = string
  default     = ""
}

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "subnetwork" {
  description = "Subnet name"
  type        = string
}

variable "pods_ip_range_name" {
  description = "Name of secondary IP range for pods"
  type        = string
  default     = "gke-pods"
}

variable "services_ip_range_name" {
  description = "Name of secondary IP range for services"
  type        = string
  default     = "gke-services"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for master nodes (private cluster)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_cluster" {
  description = "Enable private cluster"
  type        = bool
  default     = true
}

variable "enable_private_nodes" {
  description = "Enable private nodes"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint (master only accessible privately)"
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "release_channel" {
  description = "Release channel (RAPID, REGULAR, STABLE, UNSPECIFIED)"
  type        = string
  default     = "REGULAR"
}

variable "kubernetes_version"  {
  description = "Kubernetes version (leave empty for latest in channel)"
  type        = string
  default     = null
}

variable "enable_autopilot" {
  description = "Enable GKE Autopilot mode"
  type        = bool
  default     = false
}

variable "node_pools" {
  description = "List of node pools"
  type = list(object({
    name               = string
    machine_type       = string
    min_count          = number
    max_count          = number
    disk_size_gb       = optional(number, 100)
    disk_type          = optional(string, "pd-standard")
    preemptible        = optional(bool, false)
    spot               = optional(bool, false)
    auto_repair        = optional(bool, true)
    auto_upgrade       = optional(bool, true)
    max_surge          = optional(number, 1)
    max_unavailable    = optional(number, 0)
    service_account    = optional(string, null)
    oauth_scopes       = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
    labels             = optional(map(string), {})
    tags               = optional(list(string), [])
  }))
  default = []
}

variable "workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable binary authorization"
  type        = bool
  default     = false
}

variable "enable_shielded_nodes" {
  description = "Enable shielded nodes"
  type        = bool
  default     = true
}

variable "http_load_balancing_disabled" {
  description = "Disable HTTP load balancing addon"
  type        = bool
  default     = false
}

variable "horizontal_pod_autoscaling_disabled" {
  description = "Disable horizontal pod autoscaling addon"
  type        = bool
  default     = false
}

variable "maintenance_start_time" {
  description = "Start time for maintenance window (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "labels" {
  description = "Labels to apply to the cluster"
  type        = map(string)
  default     = {}
}

variable "resource_labels" {
  description = "Labels to apply to cluster resources"
  type        = map(string)
  default     = {}
}
