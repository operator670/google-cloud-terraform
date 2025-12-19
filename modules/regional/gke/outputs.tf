output "cluster_id" {
  description = "The ID of the cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_name" {
  description = "The name of the cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The endpoint of the cluster"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_self_link" {
  description = "The self link of the cluster"
  value       = google_container_cluster.primary.self_link
}

output "cluster_location" {
  description = "The location of the cluster"
  value       = google_container_cluster.primary.location
}

output "node_pool_names" {
  description = "Names of the node pools"
  value       = [for pool in google_container_node_pool.pools : pool.name]
}

output "workload_identity_enabled" {
  description = "Whether Workload Identity is enabled"
  value       = var.workload_identity
}

output "workload_pool" {
  description = "The Workload Identity pool"
  value       = var.workload_identity ? "${var.project_id}.svc.id.goog" : null
}
