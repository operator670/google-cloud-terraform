output "folders" {
  description = "All created folders"
  value       = module.landing_zone.folders
}

output "all_projects" {
  description = "All created project IDs"
  value       = module.landing_zone.all_projects
}

output "host_projects" {
  description = "Shared VPC host projects"
  value       = module.landing_zone.host_projects
}
