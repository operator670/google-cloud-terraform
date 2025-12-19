output "bucket_name" {
  description = "The name of the bucket"
  value       = google_storage_bucket.main.name
}

output "bucket_url" {
  description = "The URL of the bucket"
  value       = google_storage_bucket.main.url
}

output "bucket_self_link" {
  description = "The self link of the bucket"
  value       = google_storage_bucket.main.self_link
}

output "bucket_location" {
  description = "The location of the bucket"
  value       = google_storage_bucket.main.location
}

output "bucket_storage_class" {
  description = "The storage class of the bucket"
  value       = google_storage_bucket.main.storage_class
}
