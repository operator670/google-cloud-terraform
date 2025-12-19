# Additional Persistent Disks
resource "google_compute_disk" "additional" {
  for_each = { for disk in var.additional_disks : disk.name => disk if disk.source == null }

  name    = each.value.name
  project = var.project_id
  zone    = var.zone
  type    = each.value.type
  size    = each.value.size_gb

  labels = var.labels
}

# Snapshot Resource Policy (Schedule)
# Only create if enable_snapshots is true AND snapshot_schedule config is provided
# AND snapshot_schedule_id is NOT provided (meaning we need to create a new schedule)
resource "google_compute_resource_policy" "snapshot" {
  count = var.enable_snapshots && var.snapshot_schedule != null && var.snapshot_schedule_id == null ? 1 : 0

  name    = var.snapshot_schedule.name
  project = var.project_id
  region  = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "02:00"
      }
    }

    retention_policy {
      max_retention_days    = var.snapshot_schedule.retention_days
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      labels = merge(var.labels, {
        snapshot_type = "automated"
      })
      storage_locations = length(var.snapshot_schedule.storage_locations) > 0 ? var.snapshot_schedule.storage_locations : [var.region]
      guest_flush       = false
    }
  }
}

# Determine which snapshot policy to use (created or existing)
locals {
  snapshot_policy_id = var.enable_snapshots ? (
    var.snapshot_schedule_id != null ? var.snapshot_schedule_id : (
      length(google_compute_resource_policy.snapshot) > 0 ? google_compute_resource_policy.snapshot[0].name : null
    )
  ) : null
}


# Instance Schedule (Start/Stop)
resource "google_compute_resource_policy" "instance_schedule" {
  count = var.enable_scheduling && var.schedule_config != null ? 1 : 0

  name    = "${var.instance_name}-schedule"
  project = var.project_id
  region  = var.region

  instance_schedule_policy {
    vm_start_schedule {
      schedule = var.schedule_config.start_schedule != null ? var.schedule_config.start_schedule : ""
    }
    vm_stop_schedule {
      schedule = var.schedule_config.stop_schedule != null ? var.schedule_config.stop_schedule : ""
    }
    time_zone = var.schedule_config.timezone
  }
}

# Attach Instance Schedule

# Attach Snapshot Policy to Boot Disk (for single instances)
resource "google_compute_disk_resource_policy_attachment" "boot_disk" {
  count = var.enable_snapshots && !var.enable_instance_group && (var.snapshot_schedule_id != null || var.snapshot_schedule != null) ? 1 : 0

  name    = local.snapshot_policy_id
  disk    = google_compute_instance.main[0].name
  zone    = var.zone
  project = var.project_id
}
