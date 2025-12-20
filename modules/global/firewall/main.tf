# Firewall Rules Module
# This module manages firewall rules for a specific VPC network.
# It is designed to be managed by a security team independently of core networking.

resource "google_compute_firewall" "rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name                    = each.value.name
  project                 = var.project_id
  network                 = var.network_name
  description             = each.value.description
  direction               = each.value.direction
  priority                = each.value.priority
  source_ranges           = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges      = each.value.direction == "EGRESS" ? each.value.ranges : null
  source_tags             = length(each.value.source_tags) > 0 ? each.value.source_tags : null
  source_service_accounts = length(each.value.source_service_accounts) > 0 ? each.value.source_service_accounts : null
  target_tags             = length(each.value.target_tags) > 0 ? each.value.target_tags : null
  target_service_accounts = length(each.value.target_service_accounts) > 0 ? each.value.target_service_accounts : null

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

# Optional Deny All Ingress Rule (Hardening)
resource "google_compute_firewall" "deny_all" {
  count = var.enable_deny_all_ingress ? 1 : 0

  name        = "${var.network_name}-deny-all-ingress"
  project     = var.project_id
  network     = var.network_name
  description = "Hardening rule: Explicitly deny all ingress traffic not permitted by other rules"
  priority    = 65535
  direction   = "INGRESS"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}
