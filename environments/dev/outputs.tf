output "network_names" {
  description = "The names of the VPC networks"
  value       = module.environment.network_names
}

output "network_ids" {
  description = "The IDs of the VPC networks"
  value       = module.environment.network_ids
}

output "network_self_links" {
  description = "The URIs of the VPC networks"
  value       = module.environment.network_self_links
}

output "subnet_ip_cidr_ranges" {
  description = "Map of subnet names to their IP CIDR ranges per network"
  value       = module.environment.subnet_ip_cidr_ranges
}

output "service_account_emails" {
  description = "Map of service account emails"
  value       = module.environment.service_account_emails
}

output "compute_instance_details" {
  description = "Detailed map of compute instances"
  value       = module.environment.compute_instance_details
}

output "instance_ips" {
  description = "Map of compute instance internal IPs"
  value       = module.environment.instance_ips
}

output "database_details" {
  description = "Detailed map of Cloud SQL databases"
  value       = module.environment.database_details
}

output "database_connection_names" {
  description = "Map of database connection names"
  value       = module.environment.database_connection_names
}

output "bucket_urls" {
  description = "Map of bucket URLs"
  value       = module.environment.bucket_urls
}

output "gke_cluster_details" {
  description = "Detailed map of GKE clusters"
  value       = module.environment.gke_cluster_details
}

output "gke_cluster_endpoints" {
  description = "Map of GKE cluster endpoints"
  value       = module.environment.gke_cluster_endpoints
}
