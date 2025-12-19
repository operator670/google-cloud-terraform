# Cloud Run Services (Multiple)
variable "cloud_run_services" {
  description = "Map of Cloud Run services to create"
  type = map(object({
    region                = string
    image                 = string
    cpu_limit             = optional(string, "1000m")
    memory_limit          = optional(string, "512Mi")
    timeout_seconds       = optional(number, 300)
    min_instances         = optional(number, 0)
    max_instances         = optional(number, 10)
    env_vars              = optional(list(object({
      name  = string
      value = string
    })), [])
    env_secrets           = optional(list(object({
      name    = string
      secret  = string
      version = optional(string, "latest")
    })), [])
    allow_unauthenticated = optional(bool, false)
    custom_labels         = optional(map(string), {})
  }))
  default = {}
}
