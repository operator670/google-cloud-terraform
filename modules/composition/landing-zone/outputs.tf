output "folders" {
  description = "Map of all created folders"
  value = merge(
    {
      for k, v in module.root_folders : k => {
        id           = v.id
        name         = v.name
        display_name = v.display_name
      }
    },
    {
      for k, v in module.child_folders : k => {
        id           = v.id
        name         = v.name
        display_name = v.display_name
      }
    }
  )
}

output "host_projects" {
  description = "Map of Shared VPC host projects"
  value = {
    for k, v in module.host_projects : k => {
      project_id = v.project_id
      number     = v.number
      name       = v.name
    }
  }
}

output "service_projects" {
  description = "Map of Shared VPC service projects"
  value = {
    for k, v in module.service_projects : k => {
      project_id = v.project_id
      number     = v.number
      name       = v.name
    }
  }
}

output "standalone_projects" {
  description = "Map of standalone projects (no Shared VPC)"
  value = {
    for k, v in module.standalone_projects : k => {
      project_id = v.project_id
      number     = v.number
      name       = v.name
    }
  }
}

output "all_projects" {
  description = "Map of all created projects"
  value = merge(
    { for k, v in module.host_projects : k => v.project_id },
    { for k, v in module.service_projects : k => v.project_id },
    { for k, v in module.standalone_projects : k => v.project_id }
  )
}
