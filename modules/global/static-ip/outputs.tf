output "global_ip_addresses" {
  description = "Map of global IP names to their addresses"
  value       = { for k, v in google_compute_global_address.global : k => v.address }
}

output "global_ip_ids" {
  description = "Map of global IP names to their IDs"
  value       = { for k, v in google_compute_global_address.global : k => v.id }
}

output "global_ip_self_links" {
  description = "Map of global IP names to their self links"
  value       = { for k, v in google_compute_global_address.global : k => v.self_link }
}

output "regional_ip_addresses" {
  description = "Map of regional IP names to their addresses"
  value       = { for k, v in google_compute_address.regional : k => v.address }
}

output "regional_ip_ids" {
  description = "Map of regional IP names to their IDs"
  value       = { for k, v in google_compute_address.regional : k => v.id }
}

output "regional_ip_self_links" {
  description = "Map of regional IP names to their self links"
  value       = { for k, v in google_compute_address.regional : k => v.self_link }
}
