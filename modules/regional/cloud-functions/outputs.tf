output "function_id" {
  description = "The ID of the Cloud Function"
  value       = google_cloudfunctions2_function.main.id
}

output "function_name" {
  description = "The name of the Cloud Function"
  value       = google_cloudfunctions2_function.main.name
}

output "function_uri" {
  description = "The URI of the Cloud Function"
  value       = google_cloudfunctions2_function.main.service_config[0].uri
}

output "function_state" {
  description = "The state of the function"
  value       = google_cloudfunctions2_function.main.state
}

output "source_bucket" {
  description = "The source bucket name"
  value       = var.source_dir != null ? google_storage_bucket.function_source[0].name : var.source_archive_bucket
}
