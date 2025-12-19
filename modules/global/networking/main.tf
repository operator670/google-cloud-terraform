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

# Firewall Rules
resource "google_compute_firewall" "rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name                    = each.value.name
  project                 = var.project_id
  network                 = google_compute_network.vpc.name
  description             = each.value.description
  direction               = each.value.direction
  priority                = each.value.priority
  source_ranges           = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges      = each.value.direction == "EGRESS" ? each.value.ranges : null
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
}

# Routes
resource "google_compute_route" "routes" {
  for_each = { for route in var.routes : route.name => route }

  name              = each.value.name
  project           = var.project_id
  network           = google_compute_network.vpc.name
  description       = each.value.description
  dest_range        = each.value.dest_range
  next_hop_internet = each.value.next_hop_internet ? "default-internet-gateway" : null
  next_hop_ip       = each.value.next_hop_ip
  next_hop_instance = each.value.next_hop_instance
  next_hop_gateway  = each.value.next_hop_gateway
  priority          = each.value.priority
  tags              = each.value.tags
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
# Default Deny Ingress Rule (Hardening)
resource "google_compute_firewall" "deny_all" {
  name        = "${var.network_name}-deny-all-ingress"
  project     = var.project_id
  network     = google_compute_network.vpc.name
  description = "Hardening rule: Explicitly deny all ingress traffic not permitted by other rules"
  priority    = 65535
  direction   = "INGRESS"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}
