# Storage Buckets (Multiple)
variable "storage_buckets" {
  description = "Map of storage buckets to create"
  type = map(object({
    location           = string
    storage_class      = string
    versioning_enabled = optional(bool, false)
    lifecycle_rules    = optional(list(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                    = optional(number)
        with_state             = optional(string)
        matches_storage_class  = optional(list(string))
        created_before         = optional(string)
        num_newer_versions     = optional(number)
      })
    })), [])
    iam_bindings      = optional(list(object({
      role    = string
      members = list(string)
    })), [])
    retention_policy  = optional(object({
      retention_period = number
      is_locked        = optional(bool, false)
    }), null)
    custom_labels = optional(map(string), {})
    delete_contents_on_destroy = optional(bool, false) # Added for P2 enhancement
  }))
  default = {}
}
