resource "google_network_connectivity_hub" "main" {
  name        = var.hub_name
  project     = var.project_id
  description = var.hub_description
}

resource "google_network_connectivity_spoke" "vpc_spoke" {
  for_each = var.vpc_spokes

  name     = "${var.hub_name}-${each.key}-spoke"
  project  = var.project_id
  location = "global"
  hub      = google_network_connectivity_hub.main.id

  linked_vpc_network {
    uri = each.value
  }
}
