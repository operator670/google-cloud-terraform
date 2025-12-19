output "service_account_emails" {
  description = "Map of service account IDs to their email addresses"
  value       = { for k, v in google_service_account.service_accounts : k => v.email }
}

output "service_account_ids" {
  description = "Map of service account IDs to their resource IDs"
  value       = { for k, v in google_service_account.service_accounts : k => v.id }
}

output "service_account_unique_ids" {
  description = "Map of service account IDs to their unique IDs"
  value       = { for k, v in google_service_account.service_accounts : k => v.unique_id }
}

output "service_account_keys" {
  description = "Map of service account keys (if created)"
  value       = { for k, v in google_service_account_key.keys : k => v.private_key }
  sensitive   = true
}
