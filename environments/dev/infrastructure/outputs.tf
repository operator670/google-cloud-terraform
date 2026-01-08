output "vpc_ids" {
  description = "IDs of the created VPCs"
  value       = { for k, v in module.networking.network_names : k => v }
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = module.networking.subnet_ids
}
