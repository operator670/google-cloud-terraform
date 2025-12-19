# Databases (Multiple)
variable "databases" {
  description = "Map of Cloud SQL databases to create"
  type = map(object({
    region                = string
    database_version      = string
    tier                  = string
    ha_enabled            = optional(bool, false)
    backup_enabled        = optional(bool, true)
    backup_retention_days = optional(number, 7)
    deletion_protection   = optional(bool, false)
    databases             = optional(list(object({
      name      = string
      charset   = optional(string, "UTF8")
      collation = optional(string)
    })), [])
    users                 = optional(list(object({
      name     = string
      password = string
    })), [])
    custom_labels = optional(map(string), {})
    read_replicas = optional(list(object({ # Added for P2 enhancement
      name            = string
      tier            = string
      zone            = optional(string)
      disk_size       = optional(number)
      disk_type       = optional(string)
      user_labels     = optional(map(string))
      database_flags  = optional(list(object({
        name  = string
        value = string
      })), [])
    })), [])
  }))
  default = {}
}
