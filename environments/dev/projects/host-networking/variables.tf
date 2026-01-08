################################################################################
# Common Variables
################################################################################

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "primary_region" {
  description = "Primary GCP region"
  type        = string
  default     = "asia-south1"
}

variable "customer_name" {
  description = "Customer name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "is_shared_vpc_service" {
  description = "Whether this project is a Shared VPC service project"
  type        = bool
  default     = false
}

variable "host_project_id" {
  description = "The ID of the Shared VPC host project"
  type        = string
  default     = null
}

variable "firewall_policies" {
  description = "Map of firewall policies to create, each explicitly targeting a network"
  type = map(object({
    network_key = string
    rules = list(object({
      name                    = string
      description             = optional(string, "")
      direction               = string
      priority                = optional(number, 1000)
      ranges                  = optional(list(string), [])
      source_tags             = optional(list(string), [])
      source_service_accounts = optional(list(string), [])
      target_tags             = optional(list(string), [])
      target_service_accounts = optional(list(string), [])
      allow = optional(list(object({
        protocol = string
        ports    = optional(list(string), [])
      })), [])
      deny = optional(list(object({
        protocol = string
        ports    = optional(list(string), [])
      })), [])
    }))
  }))
  default = {}
}

################################################################################
# Workload Variables
################################################################################

variable "compute_instances" {
  description = "Map of compute instances to create"
  type = map(object({
    network_key  = optional(string, "default")
    subnet_name  = optional(string, null)
    zone         = string
    machine_type = string
    disk_size_gb = number
    disk_type    = string
    additional_disks = list(object({
      name        = string
      size_gb     = number
      type        = string
      auto_delete = bool
    }))
    enable_snapshots        = bool
    snapshot_schedule       = optional(string, "0 2 * * *")
    snapshot_retention_days = optional(number, 7)
    snapshot_schedule_id    = optional(string, null)
    enable_scheduling       = optional(bool, false)
    start_schedule          = optional(string, "0 8 * * MON-FRI")
    stop_schedule           = optional(string, "0 18 * * MON-FRI")
    deletion_protection     = optional(bool, false)
    custom_tags             = optional(list(string), [])
    custom_labels           = optional(map(string), {})
    is_spot                 = optional(bool, false)
    instance_name           = optional(string, null)
    network_project         = optional(string, null)
    image_family            = optional(string, null)
    image_project           = optional(string, null)
    service_account_email   = optional(string, null)
    key_revocation_action_type = optional(string, null)
    enable_external_ip      = optional(bool, false)
  }))
  default = {}
}

variable "storage_buckets" {
  description = "Map of storage buckets to create"
  type = map(object({
    location           = string
    storage_class      = string
    versioning_enabled = optional(bool, false)
    lifecycle_rules = optional(list(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                   = optional(number)
        with_state            = optional(string)
        matches_storage_class = optional(list(string))
        created_before        = optional(string)
        num_newer_versions    = optional(number)
      })
    })), [])
    iam_bindings = optional(list(object({
      role    = string
      members = list(string)
    })), [])
    retention_policy = optional(object({
      retention_period = number
      is_locked        = optional(bool, false)
    }), null)
    folders                    = optional(list(string), [])
    custom_labels              = optional(map(string), {})
    delete_contents_on_destroy = optional(bool, false)
  }))
  default = {}
}

variable "databases" {
  description = "Map of Cloud SQL databases to create"
  type = map(object({
    network_key           = optional(string, "default")
    region                = string
    database_version      = string
    tier                  = string
    ha_enabled            = optional(bool, false)
    backup_enabled        = optional(bool, true)
    backup_retention_days = optional(number, 7)
    deletion_protection   = optional(bool, false)
    databases = optional(list(object({
      name      = string
      charset   = optional(string, "UTF8")
      collation = optional(string)
    })), [])
    users = optional(list(object({
      name               = string
      password           = optional(string)
      password_secret_id = optional(string)
      host               = optional(string, "%")
    })), [])
    custom_labels = optional(map(string), {})
    read_replicas = optional(list(object({
      name        = string
      tier        = string
      zone        = optional(string)
      disk_size   = optional(number)
      disk_type   = optional(string)
      user_labels = optional(map(string))
      database_flags = optional(list(object({
        name  = string
        value = string
      })), [])
    })), [])
  }))
  default = {}
}

variable "gke_clusters" {
  description = "Map of GKE clusters to create"
  type = map(object({
    network_key            = optional(string, "default")
    region                 = string
    pods_ip_range_name     = string
    services_ip_range_name = string
    enable_private_cluster = optional(bool, true)
    enable_private_nodes   = optional(bool, true)
    master_ipv4_cidr_block = optional(string, "172.16.0.0/28")
    enable_autopilot       = optional(bool, false)
    node_pools = list(object({
      name         = string
      machine_type = string
      min_count    = number
      max_count    = number
      disk_size_gb = optional(number, 100)
      disk_type    = optional(string, "pd-standard")
      preemptible  = optional(bool, false)
      spot         = optional(bool, false)
      auto_repair  = optional(bool, true)
      auto_upgrade = optional(bool, true)
    }))
    workload_identity     = optional(bool, true)
    enable_network_policy = optional(bool, true)
    release_channel       = optional(string, "REGULAR")
    custom_labels         = optional(map(string), {})
    authorized_networks = optional(list(object({
      cidr_block   = string
      display_name = string
    })), [])
  }))
  default = {}
}

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
      version_id  = string
      secret_data = string
      enabled     = optional(bool, true)
    })), [])
    iam_bindings = optional(list(object({
      role    = string
      members = list(string)
    })), [])
  }))
  default = {}
}

variable "cloud_run_services" {
  description = "Map of Cloud Run services to create"
  type = map(object({
    region          = string
    image           = string
    cpu_limit       = optional(string, "1000m")
    memory_limit    = optional(string, "512Mi")
    timeout_seconds = optional(number, 300)
    min_instances   = optional(number, 0)
    max_instances   = optional(number, 10)
    env_vars = optional(list(object({
      name  = string
      value = string
    })), [])
    env_secrets = optional(list(object({
      name    = string
      secret  = string
      version = optional(string, "latest")
    })), [])
    allow_unauthenticated = optional(bool, false)
    custom_labels         = optional(map(string), {})
  }))
  default = {}
}

variable "cloud_functions" {
  description = "Map of Cloud Functions to create"
  type = map(object({
    region           = string
    runtime          = string
    entry_point      = string
    source_dir       = string
    available_memory = optional(string, "256M")
    available_cpu    = optional(string, "1")
    timeout_seconds  = optional(number, 60)
    min_instances    = optional(number, 0)
    max_instances    = optional(number, 100)
    env_vars         = optional(map(string), {})
    secret_env_vars = optional(list(object({
      key     = string
      secret  = string
      version = optional(string, "latest")
    })), [])
    trigger_http          = optional(bool, false)
    trigger_event_type    = optional(string, null)
    trigger_pubsub_topic  = optional(string, null)
    allow_unauthenticated = optional(bool, false)
    custom_labels         = optional(map(string), {})
  }))
  default = {}
}
