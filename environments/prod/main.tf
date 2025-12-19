module "environment" {
  source = "../../modules/composition/environment"

  project_id     = var.project_id
  customer_name  = var.customer_name
  environment    = var.environment
  primary_region = var.primary_region
  labels         = var.labels

  # Networking
  network_name = var.network_name
  subnet_cidr  = var.subnet_cidr
  enable_nat   = var.enable_nat
  custom_firewall_rules = var.custom_firewall_rules

  # Compute
  compute_instances = var.compute_instances

  # Storage
  storage_buckets = var.storage_buckets

  # Databases
  databases = var.databases

  # GKE
  gke_clusters = var.gke_clusters

  # Secrets
  secrets = var.secrets
  
  # Cloud Run & Functions (Variables passed through, even if module logic is partial)
  cloud_run_services = var.cloud_run_services
  cloud_functions    = var.cloud_functions
}
