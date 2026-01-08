# Environment Layer - Composition Module
# This module assembles various regional and global resources into a cohesive environment.

locals {
  resource_prefix = "${var.customer_name}-${var.environment}"
  common_labels = merge(var.labels, {
    customer    = var.customer_name
    environment = var.environment
    managed_by  = "terraform"
  })

  # Handle Legacy Networking Compatibility
  legacy_network = var.network_name != null ? {
    (var.network_name) = {
      network_name            = var.network_name
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
      exclude_from_ncc        = false
      enable_nat              = var.enable_nat
      subnets = length(var.subnets) > 0 ? var.subnets : (var.subnet_cidr != null ? [{
        subnet_name           = "${var.network_name}-subnet"
        subnet_ip             = var.subnet_cidr
        subnet_region         = var.primary_region
        subnet_private_access = true
        subnet_flow_logs      = false
        description           = "Default subnet created from legacy parameters"
        secondary_ranges      = []
      }] : [])
    }
  } : {}

  # Combine everything
  # If is_shared_vpc_service is true, we don't create networks here
  # Using for loop to maintain type consistency for empty maps
  merged_networks = {
    for k, v in merge(local.legacy_network, var.networks) : k => v
    if !var.is_shared_vpc_service
  }
}

# 1. Networking (Skip if Shared VPC Service)
module "networking" {
  source   = "../../global/networking"
  for_each = local.merged_networks

  project_id   = var.project_id
  network_name = try(each.value.network_name, null) != null ? each.value.network_name : each.key
  routing_mode = try(each.value.routing_mode, "REGIONAL")
  subnets      = try(each.value.subnets, [])

  # Forward common enable_nat flag if provided
  enable_nat = try(each.value.enable_nat, var.enable_nat)
}

# 1.1 Network Connectivity Center (NCC)
resource "google_network_connectivity_hub" "hub" {
  count       = var.enable_ncc ? 1 : 0
  name        = var.ncc_hub_name
  project     = var.project_id
  description = "Central transit hub managed by environment composition"
  labels      = local.common_labels
}

resource "google_network_connectivity_spoke" "spokes" {
  for_each = {
    for k, v in local.merged_networks : k => v
    if var.enable_ncc && !try(v.exclude_from_ncc, false)
  }

  name     = "${local.resource_prefix}-${each.key}-spoke"
  project  = var.project_id
  location = "global"
  hub      = google_network_connectivity_hub.hub[0].id
  labels   = local.common_labels

  linked_vpc_network {
    uri = module.networking[each.key].network_id
  }
}

# 2. IAM Configuration
module "iam" {
  source = "../../global/iam"

  project_id = var.project_id
  service_accounts = [
    {
      account_id   = "${local.resource_prefix}-compute-sa"
      display_name = "Service Account for Compute Instances"
      description  = "Managed by Terraform"
    },
    {
      account_id   = "${local.resource_prefix}-gke-sa"
      display_name = "Service Account for GKE Nodes"
      description  = "Managed by Terraform"
    }
  ]

  project_iam_bindings = [
    {
      role = "roles/logging.logWriter"
      members = [
        "serviceAccount:${local.resource_prefix}-compute-sa@${var.project_id}.iam.gserviceaccount.com",
        "serviceAccount:${local.resource_prefix}-gke-sa@${var.project_id}.iam.gserviceaccount.com"
      ]
    },
    {
      role = "roles/monitoring.metricWriter"
      members = [
        "serviceAccount:${local.resource_prefix}-compute-sa@${var.project_id}.iam.gserviceaccount.com",
        "serviceAccount:${local.resource_prefix}-gke-sa@${var.project_id}.iam.gserviceaccount.com"
      ]
    },
    {
      role = "roles/artifactregistry.reader"
      members = [
        "serviceAccount:${local.resource_prefix}-gke-sa@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
  ]
}

# Support for Shared VPC Service Project IAM
# Service accounts need Compute Network User role on the host project subnet/project
resource "google_project_iam_member" "network_user" {
  for_each = var.is_shared_vpc_service ? toset([
    "serviceAccount:${module.iam.service_account_emails["${local.resource_prefix}-compute-sa"]}",
    "serviceAccount:${module.iam.service_account_emails["${local.resource_prefix}-gke-sa"]}"
  ]) : toset([])

  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = each.value
}

# 3. Compute Instances
module "compute_instances" {
  source   = "../../regional/compute"
  for_each = var.compute_instances

  project_id    = var.project_id
  region        = var.primary_region
  zone          = each.value.zone
  instance_name = coalesce(each.value.instance_name, "${local.resource_prefix}-${each.key}")

  machine_type = each.value.machine_type

  # Boot disk configuration
  disk_size_gb  = each.value.disk_size_gb
  disk_type     = each.value.disk_type
  image_family  = coalesce(each.value.image_family, "debian-11")
  image_project = coalesce(each.value.image_project, "debian-cloud")

  # Additional disks
  additional_disks = each.value.additional_disks

  # Snapshot configuration
  enable_snapshots = each.value.enable_snapshots
  snapshot_schedule = each.value.enable_snapshots ? {
    name              = "${local.resource_prefix}-${each.key}-snapshot"
    description       = "Snapshots for ${each.key}"
    schedule          = each.value.snapshot_schedule
    retention_days    = each.value.snapshot_retention_days
    storage_locations = [var.primary_region]
  } : null

  # Reuse existing snapshot schedule if ID provided
  snapshot_schedule_id = each.value.snapshot_schedule_id

  # Instance scheduling
  enable_scheduling = each.value.enable_scheduling
  schedule_config = each.value.enable_scheduling ? {
    start_schedule = each.value.start_schedule
    stop_schedule  = each.value.stop_schedule
    timezone       = "Asia/Kolkata"
  } : null

  # Networking Logic:
  # - For Shared VPC: network_project = host project, network/subnet = from host project
  # - For self-managed VPC: network_project = this project, network/subnet = from module.networking
  network_project = each.value.network_project != null ? each.value.network_project : (var.is_shared_vpc_service ? var.host_project_id : var.project_id)
  network         = try(module.networking[each.value.network_key].network_name, each.value.network_key)
  # For Shared VPC, module.networking won't exist, so try() falls back to each.value.subnet_name
  # For self-managed VPC, uses the subnet from module.networking or defaults to standard naming
  subnetwork = try(module.networking[each.value.network_key].subnet_names[coalesce(each.value.subnet_name, "${local.resource_prefix}-subnet-${var.primary_region}")], each.value.subnet_name)

  tags   = concat(["ssh", var.environment], each.value.custom_tags)
  labels = merge(local.common_labels, each.value.custom_labels)

  service_account_email  = coalesce(each.value.service_account_email, module.iam.service_account_emails["${local.resource_prefix}-compute-sa"])
  service_account_scopes = ["cloud-platform"]

  is_spot                    = each.value.is_spot
  deletion_protection        = each.value.deletion_protection
  key_revocation_action_type = each.value.key_revocation_action_type
  enable_external_ip         = each.value.enable_external_ip
  boot_disk_auto_delete      = each.value.boot_disk_auto_delete
}

# 4. Storage Buckets
module "storage_buckets" {
  source   = "../../regional/storage"
  for_each = var.storage_buckets

  project_id         = var.project_id
  bucket_name        = "${local.resource_prefix}-${each.key}"
  location           = each.value.location
  storage_class      = each.value.storage_class
  versioning_enabled = each.value.versioning_enabled
  lifecycle_rules    = each.value.lifecycle_rules
  iam_bindings       = each.value.iam_bindings
  retention_policy   = each.value.retention_policy
  folders            = each.value.folders
  labels             = merge(local.common_labels, each.value.labels)
  force_destroy      = each.value.force_destroy
}

# 5. SQL Databases
module "databases" {
  source   = "../../regional/database"
  for_each = var.databases

  project_id            = var.project_id
  instance_name         = "${local.resource_prefix}-${each.key}"
  network               = try(module.networking[each.value.network_key].network_id, each.value.network_key)
  region                = each.value.region
  database_version      = each.value.database_version
  tier                  = each.value.tier
  ha_enabled            = each.value.ha_enabled
  backup_enabled        = each.value.backup_enabled
  backup_retention_days = each.value.backup_retention_days
  deletion_protection   = each.value.deletion_protection

  databases = each.value.databases
  users     = each.value.users

  labels        = merge(local.common_labels, each.value.labels)
  read_replicas = each.value.read_replicas
}

# 6. GKE Clusters
module "gke_clusters" {
  source   = "../../regional/gke"
  for_each = var.gke_clusters

  project_id             = var.project_id
  cluster_name           = "${local.resource_prefix}-${each.key}"
  network                = try(module.networking[each.value.network_key].network_name, each.value.network_key)
  subnetwork             = try(module.networking[each.value.network_key].subnet_names["${local.resource_prefix}-subnet-${each.value.region}"], each.value.network_key)
  region                 = each.value.region
  pods_ip_range_name     = each.value.pods_ip_range_name
  services_ip_range_name = each.value.services_ip_range_name
  enable_private_cluster = each.value.enable_private_cluster
  enable_private_nodes   = each.value.enable_private_nodes
  master_ipv4_cidr_block = each.value.master_ipv4_cidr_block
  enable_autopilot       = each.value.enable_autopilot

  # Inject the standard service account if not provided per pool
  node_pools = [
    for pool in each.value.node_pools : merge(pool, {
      service_account = coalesce(pool.service_account, module.iam.service_account_emails["${local.resource_prefix}-gke-sa"])
    })
  ]

  workload_identity          = each.value.workload_identity
  enable_network_policy      = each.value.enable_network_policy
  release_channel            = each.value.release_channel
  labels                     = merge(local.common_labels, each.value.custom_labels)
  master_authorized_networks = each.value.authorized_networks
}

# 7. Secrets (Global module handles the map)
module "secrets" {
  source = "../../global/secret-manager"

  project_id = var.project_id
  # Merge common labels into each secret's labels
  secrets = {
    for k, v in var.secrets : k => merge(v, {
      labels = merge(local.common_labels, v.labels)
    })
  }
}

# 8. Cloud Run
module "cloud_run" {
  source   = "../../regional/cloud-run"
  for_each = var.cloud_run_services

  project_id            = var.project_id
  service_name          = "${local.resource_prefix}-${each.key}"
  region                = each.value.region
  image                 = each.value.image
  cpu_limit             = each.value.cpu_limit
  memory_limit          = each.value.memory_limit
  timeout_seconds       = each.value.timeout_seconds
  min_instances         = each.value.min_instances
  max_instances         = each.value.max_instances
  env_vars              = each.value.env_vars
  env_secrets           = each.value.env_secrets
  allow_unauthenticated = each.value.allow_unauthenticated
  labels                = merge(local.common_labels, each.value.labels)
}

# 9. Cloud Functions
module "cloud_functions" {
  source   = "../../regional/cloud-functions"
  for_each = var.cloud_functions

  project_id            = var.project_id
  function_name         = "${local.resource_prefix}-${each.key}"
  region                = each.value.region
  runtime               = each.value.runtime
  entry_point           = each.value.entry_point
  source_dir            = each.value.source_dir
  available_memory      = each.value.available_memory
  available_cpu         = each.value.available_cpu
  timeout_seconds       = each.value.timeout_seconds
  min_instances         = each.value.min_instances
  max_instances         = each.value.max_instances
  env_vars              = each.value.env_vars
  secret_env_vars       = each.value.secret_env_vars
  trigger_http          = each.value.trigger_http
  trigger_event_type    = each.value.trigger_event_type
  trigger_pubsub_topic  = each.value.trigger_pubsub_topic
  allow_unauthenticated = each.value.allow_unauthenticated
  labels                = merge(local.common_labels, each.value.labels)
}
