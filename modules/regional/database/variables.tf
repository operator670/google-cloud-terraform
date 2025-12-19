variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region (e.g., asia-south1)"
  type        = string
}

variable "instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "database_version" {
  description = "Database version (POSTGRES_15, POSTGRES_14, MYSQL_8_0, MYSQL_5_7)"
  type        = string
  validation {
    condition = can(regex("^(POSTGRES|MYSQL)_", var.database_version))
    error_message = "Database version must start with POSTGRES_ or MYSQL_."
  }
}

variable "tier" {
  description = "Machine tier (e.g., db-custom-2-7680, db-n1-standard-1)"
  type        = string
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Disk type (PD_SSD or PD_HDD)"
  type        = string
  default     = "PD_SSD"
}

variable "disk_autoresize" {
  description = "Enable automatic disk size increase"
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "Maximum disk size in GB for autoresize"
  type        = number
  default     = 0 # 0 means no limit
}

variable "network" {
  description = "VPC network self link for private IP"
  type        = string
}

variable "ha_enabled" {
  description = "Enable high availability"
  type        = bool
  default     = false
}

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "Backup start time in HH:MM format (UTC)"
  type        = string
  default     = "03:00"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = false
}

variable "maintenance_window_day" {
  description = "Day of week for maintenance (1-7, Monday-Sunday)"
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "Hour of day for maintenance (0-23)"
  type        = number
  default     = 3
}

variable "database_flags" {
  description = "Database flags to set"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "require_ssl" {
  description = "Require SSL for connections"
  type        = bool
  default     = true
}

variable "authorized_networks" {
  description = "Authorized networks for public IP access"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "databases" {
  description = "List of databases to create"
  type = list(object({
    name      = string
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.UTF8")
  }))
  default = []
}

variable "users" {
  description = "List of users to create"
  type = list(object({
    name               = string
    password           = optional(string) # Optional if using secret_id
    password_secret_id = optional(string) # Resource ID like projects/P/secrets/S/versions/latest
    host               = optional(string, "%")
  }))
  default   = []
  sensitive = true
}
variable "read_replicas" {
  description = "List of read replicas to create"
  type = list(object({
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
  }))
  default = []
}
