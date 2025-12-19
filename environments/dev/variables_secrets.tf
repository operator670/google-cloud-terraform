variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    secret_id = string
    replication_policy = optional(object({
      automatic = optional(bool, true)
      user_managed = optional(object({
        replicas = list(object({
          location = string
        }))
      }))
    }), { automatic = true })
    labels = optional(map(string), {})
    versions = optional(list(object({
      version_id = string
      secret_data = string
      enabled    = optional(bool, true)
    })), [])
    iam_bindings = optional(list(object({
      role    = string
      members = list(string)
    })), [])
  }))
  default = {}
}
