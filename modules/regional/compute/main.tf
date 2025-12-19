# Compute Instance
resource "google_compute_instance" "main" {
  count = var.enable_instance_group ? 0 : 1

  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags   = var.tags
  labels = var.labels

  # Advanced Options
  min_cpu_platform            = var.min_cpu_platform
  deletion_protection         = var.deletion_protection
  allow_stopping_for_update   = var.allow_stopping_for_update
  can_ip_forward              = var.can_ip_forward
  hostname                    = var.hostname
  enable_display              = var.enable_display

  # Boot Disk
  boot_disk {
    initialize_params {
      image = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }

  # Additional Disks
  dynamic "attached_disk" {
    for_each = var.additional_disks
    content {
      source      = attached_disk.value.source != null ? attached_disk.value.source : google_compute_disk.additional[attached_disk.value.name].id
      device_name = attached_disk.value.device_name
      mode        = attached_disk.value.mode
    }
  }

  # Guest Accelerators (GPUs)
  dynamic "guest_accelerator" {
    for_each = var.guest_accelerators
    content {
      type  = guest_accelerator.value.type
      count = guest_accelerator.value.count
    }
  }

  # Scheduling
  scheduling {
    on_host_maintenance = length(var.guest_accelerators) > 0 ? "TERMINATE" : "MIGRATE"
    automatic_restart   = true
    preemptible         = false
  }

  # Shielded VM
  dynamic "shielded_instance_config" {
    for_each = var.enable_shielded_vm ? [1] : []
    content {
      enable_secure_boot          = var.shielded_instance_config != null ? var.shielded_instance_config.enable_secure_boot : false
      enable_vtpm                 = var.shielded_instance_config != null ? var.shielded_instance_config.enable_vtpm : true
      enable_integrity_monitoring = var.shielded_instance_config != null ? var.shielded_instance_config.enable_integrity_monitoring : true
    }
  }

  # Confidential Computing
  dynamic "confidential_instance_config" {
    for_each = var.enable_confidential_compute ? [1] : []
    content {
      enable_confidential_compute = true
    }
  }

  # Advanced Machine Features
  dynamic "advanced_machine_features" {
    for_each = var.enable_nested_virtualization ? [1] : []
    content {
      enable_nested_virtualization = var.enable_nested_virtualization
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  metadata = merge(
    var.metadata,
    var.startup_script != "" ? { startup-script = var.startup_script } : {}
  )

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [google_compute_disk.additional]
}

# Instance Template for Managed Instance Group
resource "google_compute_instance_template" "main" {
  count = var.enable_instance_group ? 1 : 0

  name_prefix  = "${var.instance_name}-template-"
  machine_type = var.machine_type
  project      = var.project_id
  region       = var.region

  tags   = var.tags
  labels = var.labels

  disk {
    source_image = "projects/${var.image_project}/global/images/family/${var.image_family}"
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  metadata = merge(
    var.metadata,
    var.startup_script != "" ? { startup-script = var.startup_script } : {}
  )

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Health Check
resource "google_compute_health_check" "main" {
  count = var.enable_instance_group ? 1 : 0

  name    = "${var.instance_name}-health-check"
  project = var.project_id

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }
}

# Regional Managed Instance Group
resource "google_compute_region_instance_group_manager" "main" {
  count = var.enable_instance_group ? 1 : 0

  name    = "${var.instance_name}-mig"
  project = var.project_id
  region  = var.region

  base_instance_name = var.instance_name
  target_size        = var.instance_group_size

  version {
    instance_template = google_compute_instance_template.main[0].id
  }

  named_port {
    name = "http"
    port = var.health_check_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.main[0].id
    initial_delay_sec = 300
  }

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 3
    max_unavailable_fixed        = 0
    instance_redistribution_type = "PROACTIVE"
  }
}

# Autoscaler
resource "google_compute_region_autoscaler" "main" {
  count = var.enable_instance_group ? 1 : 0

  name    = "${var.instance_name}-autoscaler"
  project = var.project_id
  region  = var.region
  target  = google_compute_region_instance_group_manager.main[0].id

  autoscaling_policy {
    min_replicas    = var.autoscaling_min_replicas
    max_replicas    = var.autoscaling_max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = var.autoscaling_cpu_target
    }
  }
}
