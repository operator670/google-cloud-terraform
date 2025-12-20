# VPC Network (Global)
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
  description             = var.description
}

# Subnets (Regional, but managed in networking module)
resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.subnet_name => subnet }

  name                     = each.value.subnet_name
  project                  = var.project_id
  region                   = each.value.subnet_region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = each.value.subnet_ip
  private_ip_google_access = each.value.subnet_private_access
  description              = each.value.description

  dynamic "log_config" {
    for_each = each.value.subnet_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}


# Routes
resource "google_compute_route" "routes" {
  for_each = { for route in var.routes : route.name => route }

  name             = each.value.name
  project          = var.project_id
  network          = google_compute_network.vpc.name
  description      = each.value.description
  dest_range       = each.value.dest_range
  next_hop_gateway = each.value.next_hop_internet ? "default-internet-gateway" : each.value.next_hop_gateway
  priority         = each.value.priority
  tags             = each.value.tags
}

# Cloud Router (for Cloud NAT)
resource "google_compute_router" "router" {
  for_each = var.enable_nat ? toset(var.nat_regions) : []

  name    = "${var.network_name}-router-${each.value}"
  project = var.project_id
  region  = each.value
  network = google_compute_network.vpc.id
}

# Cloud NAT
resource "google_compute_router_nat" "nat" {
  for_each = var.enable_nat ? toset(var.nat_regions) : []

  name                               = "${var.network_name}-nat-${each.value}"
  project                            = var.project_id
  region                             = each.value
  router                             = google_compute_router.router[each.value].name
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = var.nat_log_config_enable
    filter = var.nat_log_config_filter
  }
}
