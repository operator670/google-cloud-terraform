module "project_workload" {
  source = "../../../../modules/composition/environment"

  project_id     = var.project_id
  customer_name  = var.customer_name
  environment    = var.environment
  primary_region = var.primary_region
  labels         = var.labels

  # Networking is managed centrally in infrastructure/
  is_shared_vpc_service = true
  host_project_id       = "tws-lz-host-networking"
  networks              = {}

  # Define your resources here or in .auto.tfvars
  compute_instances  = var.compute_instances
  storage_buckets    = var.storage_buckets
  databases          = var.databases
  gke_clusters       = var.gke_clusters
  firewall_policies  = var.firewall_policies
  secrets            = var.secrets
  cloud_run_services = var.cloud_run_services
  cloud_functions    = var.cloud_functions
}
