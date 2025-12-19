# Compute Instances (Multiple)
variable "compute_instances" {
  description = "Map of compute instances to create"
  type = map(object({
    zone                     = string
    machine_type             = string
    disk_size_gb             = number
    disk_type                = string
    additional_disks         = list(object({
      name        = string
      size_gb     = number
      type        = string
      auto_delete = bool
    }))
    enable_snapshots         = bool
    snapshot_schedule        = optional(string, "0 2 * * *")
    snapshot_retention_days  = optional(number, 7)
    snapshot_schedule_id     = optional(string, null)  # ID of existing schedule to reuse
    enable_scheduling        = optional(bool, false)
    start_schedule           = optional(string, "0 8 * * MON-FRI")
    stop_schedule            = optional(string, "0 18 * * MON-FRI")
    deletion_protection      = optional(bool, false)
    custom_tags              = optional(list(string), [])
    custom_labels            = optional(map(string), {})
    is_spot                  = optional(bool, false) # Added for P2 enhancement
  }))
  default = {}
}
