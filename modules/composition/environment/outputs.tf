output "network_name" {
  description = "The name of the VPC network"
  value       = module.networking.network_name
}

output "network_self_link" {
  description = "The URI of the VPC network"
  value       = module.networking.network_self_link
}

output "service_account_emails" {
  description = "Map of service account emails"
  value       = module.iam.service_account_emails
}

output "instance_ips" {
  description = "Map of compute instance internal IPs"
  value       = { for k, v in module.compute_instances : k => v.internal_ip }
}

output "database_connection_names" {
  description = "Map of database connection names"
  value       = { for k, v in module.databases : k => v.instance_connection_name }
}

output "bucket_urls" {
  description = "Map of bucket URLs"
  value       = { for k, v in module.storage_buckets : k => v.url }
}

output "gke_cluster_endpoints" {
  description = "Map of GKE cluster endpoints"
  value       = { for k, v in module.gke_clusters : k => v.endpoint }
}
