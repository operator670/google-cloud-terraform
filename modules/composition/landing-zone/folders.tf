# Create root-level folders first
module "root_folders" {
  for_each = local.root_folders

  source       = "../../global/resource-hierarchy"
  display_name = each.key
  parent       = var.parent_id
}

# Create child folders (depends on root folders)
module "child_folders" {
  for_each = local.child_folders

  source       = "../../global/resource-hierarchy"
  display_name = each.key
  parent       = local.folder_parents[each.key] == "root" ? var.parent_id : module.root_folders[each.value.parent].name

  # Ensure parent folders are created first
  depends_on = [module.root_folders]
}

# Combined folder output map for project references
locals {
  all_folders = merge(
    { for k, v in module.root_folders : k => v },
    { for k, v in module.child_folders : k => v }
  )
}

