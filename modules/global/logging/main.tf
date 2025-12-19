# Project-level Log Sinks
resource "google_logging_project_sink" "sinks" {
  for_each = var.log_sinks

  name        = each.value.name
  project     = var.project_id
  destination = each.value.destination
  filter      = each.value.filter
  description = each.value.description
  disabled    = each.value.disabled

  unique_writer_identity = each.value.unique_writer_identity
}
