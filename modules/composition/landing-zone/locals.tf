# Parse YAML configuration
locals {
  config = yamldecode(file(var.config_file))

  # Build folder map with full paths for dependency resolution
  folders_raw = { for f in local.config.folders : f.name => f }

  # Separate folders by level for proper ordering
  root_folders  = { for k, v in local.folders_raw : k => v if v.parent == "root" }
  child_folders = { for k, v in local.folders_raw : k => v if v.parent != "root" }

  # Build folder hierarchy map (folder_name => parent_folder_name)
  folder_parents = { for k, v in local.folders_raw : k => v.parent }

  # Projects configuration
  projects = local.config.projects

  # Separate host and service projects for dependency management
  host_projects    = { for k, v in local.projects : k => v if try(v.is_shared_vpc_host, false) == true }
  service_projects = { for k, v in local.projects : k => v if try(v.shared_vpc_host, null) != null }
  standalone_projects = {
    for k, v in local.projects : k => v
    if try(v.is_shared_vpc_host, false) == false && try(v.shared_vpc_host, null) == null
  }
}
