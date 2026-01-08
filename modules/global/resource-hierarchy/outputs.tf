output "name" {
  description = "The resource name of the folder (e.g., folders/123)."
  value       = google_folder.main.name
}

output "id" {
  description = "The folder ID."
  value       = google_folder.main.id
}

output "display_name" {
  description = "The folder's display name."
  value       = google_folder.main.display_name
}
