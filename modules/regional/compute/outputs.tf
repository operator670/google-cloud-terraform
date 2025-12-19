output "instance_id" {
  description = "The ID of the compute instance"
  value       = var.enable_instance_group ? null : try(google_compute_instance.main[0].id, null)
}

output "instance_name" {
  description = "The name of the compute instance"
  value       = var.enable_instance_group ? null : try(google_compute_instance.main[0].name, null)
}

output "instance_self_link" {
  description = "The self link of the compute instance"
  value       = var.enable_instance_group ? null : try(google_compute_instance.main[0].self_link, null)
}

output "instance_internal_ip" {
  description = "The internal IP address of the instance"
  value       = var.enable_instance_group ? null : try(google_compute_instance.main[0].network_interface[0].network_ip, null)
}

output "instance_template_id" {
  description = "The ID of the instance template"
  value       = var.enable_instance_group ? try(google_compute_instance_template.main[0].id, null) : null
}

output "instance_template_self_link" {
  description = "The self link of the instance template"
  value       = var.enable_instance_group ? try(google_compute_instance_template.main[0].self_link, null) : null
}

output "instance_group_manager_id" {
  description = "The ID of the instance group manager"
  value       = var.enable_instance_group ? try(google_compute_region_instance_group_manager.main[0].id, null) : null
}

output "instance_group_manager_self_link" {
  description = "The self link of the instance group manager"
  value       = var.enable_instance_group ? try(google_compute_region_instance_group_manager.main[0].self_link, null) : null
}

output "instance_group_url" {
  description = "The URL of the instance group"
  value       = var.enable_instance_group ? try(google_compute_region_instance_group_manager.main[0].instance_group, null) : null
}

output "health_check_id" {
  description = "The ID of the health check"
  value       = var.enable_instance_group ? try(google_compute_health_check.main[0].id, null) : null
}

output "autoscaler_id" {
  description = "The ID of the autoscaler"
  value       = var.enable_instance_group ? try(google_compute_region_autoscaler.main[0].id, null) : null
}
