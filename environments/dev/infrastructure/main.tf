# Infrastructure Layer
# Manages shared resources like VPCs, NCC Hubs, and Global Policies.

module "networking" {
  source = "../../../modules/composition/environment"

  project_id     = var.project_id
  customer_name  = var.customer_name
  environment    = var.environment
  primary_region = var.primary_region
  labels         = var.labels

  enable_ncc   = var.enable_ncc
  ncc_hub_name = var.ncc_hub_name

  networks          = var.networks
  network_name      = null
  subnet_cidr       = null
  enable_nat        = var.enable_nat
  subnets           = []
  firewall_policies = var.firewall_policies

  compute_instances = {}
  storage_buckets   = {}
  databases         = {}
  gke_clusters      = {}
}
