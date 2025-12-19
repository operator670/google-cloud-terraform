# Cloud Functions (Multiple)
variable "cloud_functions" {
  description = "Map of Cloud Functions to create"
  type = map(object({
    region               = string
    runtime              = string
    entry_point          = string
    source_dir           = string
    available_memory     = optional(string, "256M")
    available_cpu        = optional(string, "1")
    timeout_seconds      = optional(number, 60)
    min_instances        = optional(number, 0)
    max_instances        = optional(number, 100)
    env_vars             = optional(map(string), {})
    secret_env_vars      = optional(list(object({
      key    = string
      secret = string
      version = optional(string, "latest")
    })), [])
    trigger_http         = optional(bool, false)
    trigger_event_type   = optional(string, null)
    trigger_pubsub_topic = optional(string, null)
    allow_unauthenticated = optional(bool, false)
    custom_labels        = optional(map(string), {})
  }))
  default = {}
}
