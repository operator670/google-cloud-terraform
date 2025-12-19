output "network_name" {
  description = "The name of the VPC network"
  value       = module.environment.network_name
}

output "network_self_link" {
  description = "The URI of the VPC network"
  value       = module.environment.network_self_link
}

output "service_account_emails" {
  description = "Map of service account emails"
  value       = module.environment.service_account_emails
}

output "instance_ips" {
  description = "Map of compute instance internal IPs"
  value       = module.environment.instance_ips
}

output "database_connection_names" {
  description = "Map of database connection names"
  value       = module.environment.database_connection_names
}

output "bucket_urls" {
  description = "Map of bucket URLs"
  value       = module.environment.bucket_urls
}

output "gke_cluster_endpoints" {
  description = "Map of GKE cluster endpoints"
  value       = module.environment.gke_cluster_endpoints
}
