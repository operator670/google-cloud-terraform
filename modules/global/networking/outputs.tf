output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "network_self_link" {
  description = "The self link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_names" {
  description = "Map of subnet names to their self links"
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.name }
}

output "subnet_self_links" {
  description = "Map of subnet names to their self links"
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.self_link }
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.id }
}

output "subnet_ip_cidr_ranges" {
  description = "Map of subnet names to their IP CIDR ranges"
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.ip_cidr_range }
}

output "subnet_regions" {
  description = "Map of subnet names to their regions"
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.region }
}

output "router_names" {
  description = "Names of created Cloud Routers"
  value       = { for k, v in google_compute_router.router : k => v.name }
}

output "nat_names" {
  description = "Names of created Cloud NAT gateways"
  value       = { for k, v in google_compute_router_nat.nat : k => v.name }
}
