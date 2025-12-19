output "secret_ids" {
  description = "Map of secret keys to IDs"
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.id }
}

output "secret_names" {
  description = "Map of secret keys to names"
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.name }
}

output "secret_version_ids" {
  description = "Map of version keys to IDs"
  value       = { for k, v in google_secret_manager_secret_version.versions : k => v.id }
}
