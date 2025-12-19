# Monitoring Dashboards
resource "google_monitoring_dashboard" "dashboards" {
  for_each = var.dashboards

  project        = var.project_id
  dashboard_json = each.value.dashboard_json
}

# Monitoring Alert Policies
resource "google_monitoring_alert_policy" "policies" {
  for_each = var.alert_policies

  project      = var.project_id
  display_name = each.value.display_name
  combiner     = each.value.combiner
  enabled      = each.value.enabled

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_threshold" {
        for_each = conditions.value.condition_threshold != null ? [conditions.value.condition_threshold] : []
        content {
          filter          = condition_threshold.value.filter
          duration        = condition_threshold.value.duration
          comparison      = condition_threshold.value.comparison
          threshold_value = condition_threshold.value.threshold_value

          dynamic "trigger" {
            for_each = condition_threshold.value.trigger != null ? [condition_threshold.value.trigger] : []
            content {
              count   = trigger.value.count
              percent = trigger.value.percent
            }
          }

          dynamic "aggregations" {
            for_each = condition_threshold.value.aggregations
            content {
              alignment_period     = aggregations.value.alignment_period
              per_series_aligner   = aggregations.value.per_series_aligner
              cross_series_reducer = aggregations.value.cross_series_reducer
              group_by_fields      = aggregations.value.group_by_fields
            }
          }
        }
      }
    }
  }

  notification_channels = each.value.notification_channels

  user_labels = {
    severity = each.value.severity
  }
}
