# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region

  description = var.description

  # Autopilot or Standard
  enable_autopilot = var.enable_autopilot

  # Network configuration
  network    = var.network
  subnetwork = var.subnetwork

  # IP allocation policy for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_ip_range_name
    services_secondary_range_name = var.services_ip_range_name
  }

  # Private cluster configuration
  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      enable_private_nodes    = var.enable_private_nodes
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  # Master authorized networks
  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Workload Identity
  dynamic "workload_identity_config" {
    for_each = var.workload_identity ? [1] : []
    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
  }

  # Network policy
  dynamic "network_policy" {
    for_each = var.enable_network_policy ? [1] : []
    content {
      enabled  = true
      provider = "PROVIDER_UNSPECIFIED"
    }
  }

  # Binary authorization
  dynamic "binary_authorization" {
    for_each = var.enable_binary_authorization ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  # Shielded nodes
  dynamic "enable_shielded_nodes" {
    for_each = var.enable_shielded_nodes ? [1] : []
    content {
      enabled = true
    }
  }

  # Addons
  addons_config {
    http_load_balancing {
      disabled = var.http_load_balancing_disabled
    }
    horizontal_pod_autoscaling {
      disabled = var.horizontal_pod_autoscaling_disabled
    }
  }

  # Release channel
  release_channel {
    channel = var.release_channel
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  # Labels
  resource_labels = merge(var.labels, var.resource_labels)

  # For Standard clusters, we manage node pools separately
  # Remove the default node pool
  remove_default_node_pool = var.enable_autopilot ? false : true
  initial_node_count       = var.enable_autopilot ? null : 1

  lifecycle {
    ignore_changes = [
      node_pool,
      initial_node_count,
    ]
  }
}

# Node Pools (for Standard clusters only)
resource "google_container_node_pool" "pools" {
  for_each = var.enable_autopilot ? {} : { for pool in var.node_pools : pool.name => pool }

  name     = each.value.name
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name

  initial_node_count = each.value.min_count

  autoscaling {
    min_node_count = each.value.min_count
    max_node_count = each.value.max_count
  }

  management {
    auto_repair  = each.value.auto_repair
    auto_upgrade = each.value.auto_upgrade
  }

  upgrade_settings {
    max_surge       = each.value.max_surge
    max_unavailable = each.value.max_unavailable
  }

  node_config {
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    disk_type    = each.value.disk_type
    preemptible  = each.value.preemptible
    spot         = each.value.spot

    service_account = each.value.service_account
    oauth_scopes    = each.value.oauth_scopes

    labels = each.value.labels
    tags   = each.value.tags

    # Workload Identity
    dynamic "workload_metadata_config" {
      for_each = var.workload_identity ? [1] : []
      content {
        mode = "GKE_METADATA"
      }
    }

    # Shielded instance config
    shielded_instance_config {
      enable_secure_boot          = var.enable_shielded_nodes
      enable_integrity_monitoring = var.enable_shielded_nodes
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
