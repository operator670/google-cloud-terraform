output "hub_id" {
  value = google_network_connectivity_hub.main.id
}

output "spoke_ids" {
  value = { for k, v in google_network_connectivity_spoke.vpc_spoke : k => v.id }
}
