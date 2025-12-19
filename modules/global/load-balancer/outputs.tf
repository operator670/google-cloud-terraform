output "external_ip" {
  description = "The external IPv4 address of the load balancer"
  value       = google_compute_global_address.default.address
}

output "external_ipv6" {
  description = "The external IPv6 address of the load balancer"
  value       = var.create_ipv6_address ? google_compute_global_address.ipv6[0].address : null
}

output "url_map_id" {
  description = "The ID of the URL map"
  value       = google_compute_url_map.default.id
}

output "backend_services" {
  description = "Map of backend service names to their IDs"
  value       = { for k, v in google_compute_backend_service.default : k => v.id }
}

output "health_check_ids" {
  description = "Map of health check names to their IDs"
  value       = { for k, v in google_compute_health_check.default : k => v.id }
}

output "ssl_certificate_ids" {
  description = "Map of SSL certificate domains to their IDs"
  value       = { for k, v in google_compute_managed_ssl_certificate.default : k => v.id }
}
