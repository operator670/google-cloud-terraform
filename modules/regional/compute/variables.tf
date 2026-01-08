variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region (e.g., asia-south1)"
  type        = string
}

variable "zone" {
  description = "GCP Zone (e.g., asia-south1-a)"
  type        = string
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
  default     = "e2-medium"
}

variable "image_family" {
  description = "OS image family"
  type        = string
  default     = "debian-11"
}

variable "image_project" {
  description = "Project containing the OS image"
  type        = string
  default     = "debian-cloud"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

variable "boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted. Set to false to preserve boot disk."
  type        = bool
  default     = true
}

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "subnetwork" {
  description = "Subnet name"
  type        = string
}

variable "network_project" {
  description = "Project ID of the network host (for Shared VPC)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Network tags for firewall rules"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "metadata" {
  description = "Instance metadata"
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "Startup script for the instance"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "Service account email for the instance"
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "Service account scopes"
  type        = list(string)
  default     = ["cloud-platform"]
}

# Instance Group Variables
variable "enable_instance_group" {
  description = "Enable managed instance group"
  type        = bool
  default     = false
}

variable "instance_group_size" {
  description = "Target size for the instance group"
  type        = number
  default     = 2
}

variable "autoscaling_min_replicas" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "autoscaling_max_replicas" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization for autoscaling"
  type        = number
  default     = 0.6
}

variable "health_check_port" {
  description = "Port for health check"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path for HTTP health check"
  type        = string
  default     = "/"
}

# Additional Disks
variable "is_spot" {
  description = "Whether to use Spot VMs (provisioning_model = SPOT, preemptible = true)"
  type        = bool
  default     = false
}

variable "additional_disks" {
  description = "List of additional disks to attach"
  type = list(object({
    name        = string
    size_gb     = number
    type        = optional(string, "pd-standard")
    source      = optional(string, null)
    auto_delete = optional(bool, true)
    mode        = optional(string, "READ_WRITE")
    device_name = optional(string, null)
  }))
  default = []
}


# Snapshot Configuration
variable "enable_snapshots" {
  description = "Enable automated snapshots"
  type        = bool
  default     = false
}

variable "snapshot_schedule" {
  description = "Snapshot schedule configuration"
  type = object({
    name              = string
    description       = optional(string, "")
    schedule          = string # e.g., "0 2 * * *" (cron format)
    retention_days    = optional(number, 7)
    storage_locations = optional(list(string), [])
  })
  default = null
}

variable "snapshot_schedule_id" {
  description = "ID of existing snapshot schedule to use (if provided, snapshot_schedule is ignored and existing schedule is used)"
  type        = string
  default     = null
}

# Instance Scheduling
variable "enable_scheduling" {
  description = "Enable instance start/stop scheduling"
  type        = bool
  default     = false
}

variable "schedule_config" {
  description = "Instance schedule configuration"
  type = object({
    start_schedule = optional(string, null) # e.g., "0 8 * * MON-FRI"
    stop_schedule  = optional(string, null) # e.g., "0 18 * * MON-FRI"
    timezone       = optional(string, "UTC")
  })
  default = null
}

# Guest Accelerators (GPUs)
variable "guest_accelerators" {
  description = "List of guest accelerators (GPUs)"
  type = list(object({
    type  = string
    count = number
  }))
  default = []
}

# Shielded VM Configuration
variable "enable_shielded_vm" {
  description = "Enable Shielded VM features"
  type        = bool
  default     = false
}

variable "shielded_instance_config" {
  description = "Shielded VM configuration"
  type = object({
    enable_secure_boot          = optional(bool, false)
    enable_vtpm                 = optional(bool, true)
    enable_integrity_monitoring = optional(bool, true)
  })
  default = null
}

# Confidential Computing
variable "enable_confidential_compute" {
  description = "Enable Confidential VM"
  type        = bool
  default     = false
}

# Advanced Options
variable "min_cpu_platform" {
  description = "Minimum CPU platform (e.g., Intel Cascade Lake)"
  type        = string
  default     = null
}

variable "enable_display" {
  description = "Enable virtual display"
  type        = bool
  default     = false
}

variable "allow_stopping_for_update" {
  description = "Allow instance to be stopped for configuration updates"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "hostname" {
  description = "Custom hostname for the instance"
  type        = string
  default     = null
}

variable "can_ip_forward" {
  description = "Enable IP forwarding"
  type        = bool
  default     = false
}

variable "enable_nested_virtualization" {
  description = "Enable nested virtualization"
  type        = bool
  default     = false
}

variable "key_revocation_action_type" {
  description = "Action to take when key is revoked"
  type        = string
  default     = null
}

variable "enable_external_ip" {
  description = "Whether to assign a public IP to the instance"
  type        = bool
  default     = false
}
