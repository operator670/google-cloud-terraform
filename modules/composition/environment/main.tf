locals {
  common_labels = merge(
    var.labels,
    {
      environment = var.environment
      customer    = var.customer_name
      managed_by  = "terraform"
    }
  )

  resource_prefix = "${var.customer_name}-${var.environment}"
}

# Networking Module
module "networking" {
  source = "../../global/networking"

  project_id = var.project_id

  # VPC
  network_name = var.network_name
  description  = "VPC for ${local.resource_prefix}"

  # Subnets
  subnets = [
    {
      subnet_name           = "${local.resource_prefix}-subnet-${var.primary_region}"
      subnet_ip             = var.subnet_cidr
      subnet_region         = var.primary_region
      subnet_private_access = true
      subnet_flow_logs      = true # P3 Enhancement
      description           = "Primary subnet for ${var.environment}"
      secondary_ranges = [
        {
          range_name    = "gke-pods"
          ip_cidr_range = "10.48.0.0/14"
        },
        {
          range_name    = "gke-services"
          ip_cidr_range = "10.52.0.0/20"
        }
      ]
    }
  ]

  # Firewall Rules
  firewall_rules = concat([
    {
      name        = "${local.resource_prefix}-allow-internal"
      description = "Allow internal traffic"
      direction   = "INGRESS"
      source_tags = ["${var.environment}"]
      target_tags = ["${var.environment}"]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
        }, {
        protocol = "udp"
        ports    = ["0-65535"]
        }, {
        protocol = "icmp"
      }]
    },
    {
      name        = "${local.resource_prefix}-allow-ssh"
      description = "Allow SSH from IAP"
      direction   = "INGRESS"
      ranges      = ["35.235.240.0/20"]
      target_tags = ["ssh"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
  ], var.custom_firewall_rules)

  # Cloud NAT
  enable_nat  = var.enable_nat
  nat_regions = var.enable_nat ? [var.primary_region] : []
}

# IAM Module
module "iam" {
  source = "../../global/iam"

  project_id = var.project_id

  # Service Accounts
  service_accounts = [
    {
      account_id   = "${local.resource_prefix}-compute-sa"
      display_name = "Compute SA for ${var.environment}"
      description  = "Service account for compute instances in ${var.environment}"
    },
    {
      account_id   = "${local.resource_prefix}-gke-sa"
      display_name = "GKE SA for ${var.environment}"
      description  = "Service account for GKE nodes in ${var.environment}"
    }
  ]

  # Service Account IAM Bindings (P1 Enhancement: using iam_member now)
  service_account_iam_bindings = []
}

# Secret Manager (P2 Enhancement)
module "secrets" {
  source = "../../global/secret-manager"

  project_id = var.project_id
  secrets    = var.secrets
}

# Compute Instances
module "compute_instances" {
  for_each = var.compute_instances
  source   = "../../regional/compute"

  project_id    = var.project_id
  region        = var.primary_region
  zone          = each.value.zone
  instance_name = "${local.resource_prefix}-${each.key}"
  machine_type  = each.value.machine_type
  is_spot       = each.value.is_spot # P2

  # Boot disk configuration
  disk_size_gb = each.value.disk_size_gb
  disk_type    = each.value.disk_type

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

  network    = module.networking.network_name
  subnetwork = module.networking.subnet_names["${local.resource_prefix}-subnet-${var.primary_region}"]

  tags   = concat(["ssh", var.environment], each.value.custom_tags)
  labels = merge(local.common_labels, each.value.custom_labels)

  service_account_email  = module.iam.service_account_emails["${local.resource_prefix}-compute-sa"]
  service_account_scopes = ["cloud-platform"]

  deletion_protection = each.value.deletion_protection

  depends_on = [module.networking, module.iam]
}

# Databases
module "databases" {
  for_each = var.databases
  source   = "../../regional/database"

  project_id       = var.project_id
  region           = each.value.region
  instance_name    = "${local.resource_prefix}-${each.key}"
  database_version = each.value.database_version
  tier             = each.value.tier

  network = module.networking.network_self_link

  ha_enabled            = each.value.ha_enabled
  backup_enabled        = each.value.backup_enabled
  backup_retention_days = each.value.backup_retention_days
  deletion_protection   = each.value.deletion_protection
  read_replicas         = each.value.read_replicas # P2

  labels = merge(local.common_labels, each.value.custom_labels)

  databases = each.value.databases
  users     = each.value.users

  depends_on = [module.networking]
}

# Storage Buckets
module "storage_buckets" {
  for_each = var.storage_buckets
  source   = "../../regional/storage"

  project_id    = var.project_id
  location      = each.value.location
  bucket_name   = "${local.resource_prefix}-${each.key}"
  storage_class = each.value.storage_class

  versioning_enabled = each.value.versioning_enabled
  force_destroy      = each.value.delete_contents_on_destroy # P2
  labels             = merge(local.common_labels, each.value.custom_labels)

  lifecycle_rules  = each.value.lifecycle_rules
  iam_bindings     = each.value.iam_bindings
  retention_policy = each.value.retention_policy
  folders          = each.value.folders
}

# GKE Clusters
module "gke_clusters" {
  for_each = var.gke_clusters
  source   = "../../regional/gke"

  project_id   = var.project_id
  region       = each.value.region
  cluster_name = "${local.resource_prefix}-${each.key}"

  network    = module.networking.network_name
  subnetwork = module.networking.subnet_names["${local.resource_prefix}-subnet-${each.value.region}"]

  pods_ip_range_name     = each.value.pods_ip_range_name
  services_ip_range_name = each.value.services_ip_range_name

  enable_private_cluster     = each.value.enable_private_cluster
  enable_private_nodes       = each.value.enable_private_nodes
  master_ipv4_cidr_block     = each.value.master_ipv4_cidr_block
  master_authorized_networks = each.value.authorized_networks # P2

  node_pools = each.value.node_pools

  workload_identity     = each.value.workload_identity
  enable_network_policy = each.value.enable_network_policy
  release_channel       = each.value.release_channel

  labels = merge(local.common_labels, each.value.custom_labels)

  depends_on = [module.networking]
}

# Cloud Functions
module "cloud_functions" {
  for_each              = var.cloud_functions
  source                = "../../regional/cloud-functions"
  project_id            = var.project_id
  region                = each.value.region
  function_name         = each.key
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
  labels                = merge(var.labels, each.value.custom_labels)
}
# Note on Cloud Functions/Run: I've omitted them from the blueprint momentarily to focus on the core modules we definitely have. 
# If they were direct resources in the dev environment, they should be moved here as resources, not module calls.
