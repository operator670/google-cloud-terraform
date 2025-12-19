# Generate random ID for unique instance name
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "${var.instance_name}-${random_id.db_name_suffix.hex}"
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.ha_enabled ? "REGIONAL" : "ZONAL"
    disk_type         = var.disk_type
    disk_size         = var.disk_size
    disk_autoresize   = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit

    user_labels = var.labels

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      backup_retention_settings {
        retained_backups = var.backup_retention_days
      }
      transaction_log_retention_days = var.point_in_time_recovery_enabled ? 7 : null
    }

    ip_configuration {
      ipv4_enabled    = length(var.authorized_networks) > 0
      private_network = var.network
      require_ssl     = var.require_ssl

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    maintenance_window {
      day  = var.maintenance_window_day
      hour = var.maintenance_window_hour
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      name,
    ]
  }
}

# Databases
resource "google_sql_database" "databases" {
  for_each = { for db in var.databases : db.name => db }

  name      = each.value.name
  project   = var.project_id
  instance  = google_sql_database_instance.main.name
  charset   = each.value.charset
  collation = each.value.collation
}

# Fetch secrets for users who defined password_secret_id
data "google_secret_manager_secret_version" "user_passwords" {
  for_each = {
    for user in var.users : user.name => user.password_secret_id
    if user.password_secret_id != null
  }
  secret = each.value
}

# Users
resource "google_sql_user" "users" {
  for_each = { for user in var.users : user.name => user }

  name     = each.value.name
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  
  # Priority: 1. Plain text password (if provided) 2. Secret Manager payload 3. Error
  password = each.value.password != null ? each.value.password : data.google_secret_manager_secret_version.user_passwords[each.value.name].secret_data
  
  host     = each.value.host
}
# Read Replicas
resource "google_sql_database_instance" "replicas" {
  for_each = { for replica in var.read_replicas : replica.name => replica }

  name                 = "${var.instance_name}-replica-${each.key}-${random_id.db_name_suffix.hex}"
  project              = var.project_id
  region               = var.region
  database_version     = var.database_version
  master_instance_name = google_sql_database_instance.main.name

  deletion_protection = var.deletion_protection

  settings {
    tier              = each.value.tier
    disk_type         = coalesce(each.value.disk_type, var.disk_type)
    disk_size         = coalesce(each.value.disk_size, var.disk_size)
    user_labels       = merge(var.labels, coalesce(each.value.user_labels, {}))

    ip_configuration {
      ipv4_enabled    = false # Replicas typically use private IP internally
      private_network = var.network
    }

    dynamic "database_flags" {
      for_each = each.value.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }

  depends_on = [google_sql_database_instance.main]
}
