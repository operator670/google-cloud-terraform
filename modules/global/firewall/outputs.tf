output "firewall_rule_names" {
  description = "List of firewall rule names created"
  value       = [for r in google_compute_firewall.rules : r.name]
}
