output "network_names" {
  description = "The names of the VPC networks"
  value       = { for k, v in module.networking : k => v.network_name }
}

output "network_ids" {
  description = "The IDs of the VPC networks"
  value       = { for k, v in module.networking : k => v.network_id }
}

output "network_self_links" {
  description = "The URIs of the VPC networks"
  value       = { for k, v in module.networking : k => v.network_self_link }
}

output "subnet_ids" {
  description = "Map of network names to their subnet IDs"
  value       = { for k, v in module.networking : k => v.subnet_ids }
}

output "subnet_self_links" {
  description = "Map of network names to their subnet self links"
  value       = { for k, v in module.networking : k => v.subnet_self_links }
}

output "subnet_ip_cidr_ranges" {
  description = "Map of subnet names to their IP CIDR ranges per network"
  value       = { for k, v in module.networking : k => v.subnet_ip_cidr_ranges }
}

output "service_account_emails" {
  description = "Map of service account emails"
  value       = module.iam.service_account_emails
}

output "compute_instance_details" {
  description = "Detailed map of compute instances"
  value = {
    for k, v in module.compute_instances : k => {
      name        = v.instance_name
      id          = v.instance_id
      internal_ip = v.instance_internal_ip
    }
  }
}

output "instance_ips" {
  description = "Map of compute instance internal IPs"
  value       = { for k, v in module.compute_instances : k => v.instance_internal_ip }
}

output "database_details" {
  description = "Detailed map of Cloud SQL databases"
  value = {
    for k, v in module.databases : k => {
      name            = v.instance_name
      connection_name = v.instance_connection_name
      private_ip      = v.private_ip_address
    }
  }
}

output "database_connection_names" {
  description = "Map of database connection names"
  value       = { for k, v in module.databases : k => v.instance_connection_name }
}

output "bucket_urls" {
  description = "Map of bucket URLs"
  value       = { for k, v in module.storage_buckets : k => v.bucket_url }
}

output "gke_cluster_details" {
  description = "Detailed map of GKE clusters"
  value = {
    for k, v in module.gke_clusters : k => {
      name     = v.cluster_name
      endpoint = v.cluster_endpoint
    }
  }
}

output "gke_cluster_endpoints" {
  description = "Map of GKE cluster endpoints"
  value       = { for k, v in module.gke_clusters : k => v.cluster_endpoint }
}
