# Landing Zone - Scalable, Data-Driven Configuration
# This configuration uses YAML to support hundreds of projects.

module "landing_zone" {
  source = "../../modules/composition/landing-zone"

  parent_id       = var.parent_id
  prefix          = var.prefix
  env_name        = var.env_name
  billing_account = var.billing_account
  config_file     = "${path.module}/landing-zone.yaml"
}
