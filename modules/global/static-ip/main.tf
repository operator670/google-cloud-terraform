# Global Static IP Addresses
resource "google_compute_global_address" "global" {
  for_each = { for ip in var.global_ips : ip.name => ip }

  name        = each.value.name
  project     = var.project_id
  description = each.value.description
  ip_version  = each.value.ip_version
  labels      = each.value.labels
}

# Regional Static IP Addresses
resource "google_compute_address" "regional" {
  for_each = { for ip in var.regional_ips : "${ip.region}-${ip.name}" => ip }

  name         = each.value.name
  project      = var.project_id
  region       = each.value.region
  description  = each.value.description
  ip_version   = each.value.ip_version
  address_type = each.value.address_type
  purpose      = each.value.purpose
  network_tier = each.value.address_type == "EXTERNAL" ? each.value.network_tier : null
  subnetwork   = each.value.subnetwork
  labels       = each.value.labels
}
