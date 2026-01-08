# Create Shared VPC Host Projects first
module "host_projects" {
  for_each = local.host_projects

  source = "../../global/project"

  name               = each.key
  project_id         = "${var.prefix}-${var.env_name}-${each.key}"
  folder_id          = local.all_folders[each.value.folder].id
  billing_account    = try(each.value.billing_account, var.billing_account)
  is_shared_vpc_host = true
  labels = merge(
    try(each.value.labels, {}),
    {
      managed-by   = "terraform"
      created-from = "landing-zone"
    }
  )
  deletion_policy = try(each.value.deletion_policy, "PREVENT")
  enable_lien     = try(each.value.enable_lien, true)

  depends_on = [module.root_folders, module.child_folders]
}

# Create standalone projects (no Shared VPC)
module "standalone_projects" {
  for_each = local.standalone_projects

  source = "../../global/project"

  name            = each.key
  project_id      = "${var.prefix}-${var.env_name}-${each.key}"
  folder_id       = local.all_folders[each.value.folder].id
  billing_account = try(each.value.billing_account, var.billing_account)
  labels = merge(
    try(each.value.labels, {}),
    {
      managed-by   = "terraform"
      created-from = "landing-zone"
    }
  )
  deletion_policy = try(each.value.deletion_policy, "PREVENT")
  enable_lien     = try(each.value.enable_lien, true)

  depends_on = [module.root_folders, module.child_folders]
}

# Create Shared VPC Service Projects (depends on host projects)
module "service_projects" {
  for_each = local.service_projects

  source = "../../global/project"

  name                       = each.key
  project_id                 = "${var.prefix}-${var.env_name}-${each.key}"
  folder_id                  = local.all_folders[each.value.folder].id
  billing_account            = try(each.value.billing_account, var.billing_account)
  shared_vpc_host_project_id = module.host_projects[each.value.shared_vpc_host].project_id
  labels = merge(
    try(each.value.labels, {}),
    {
      managed-by   = "terraform"
      created-from = "landing-zone"
    }
  )
  deletion_policy = try(each.value.deletion_policy, "PREVENT")
  enable_lien     = try(each.value.enable_lien, true)

  # Ensure host projects are fully created before attaching service projects
  depends_on = [module.host_projects]
}
