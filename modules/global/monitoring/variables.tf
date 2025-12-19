variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "dashboards" {
  description = "Map of monitoring dashboards to create"
  type = map(object({
    name           = string
    dashboard_json = string
  }))
  default = {}
}

variable "alert_policies" {
  description = "Map of alert policies to create"
  type = map(object({
    display_name = string
    combiner     = string
    conditions   = list(object({
      display_name = string
      condition_threshold = optional(object({
        filter          = string
        duration        = string
        comparison      = string
        threshold_value = number
        trigger         = optional(object({
          count   = optional(number)
          percent = optional(number)
        }))
        aggregations = list(object({
          alignment_period     = string
          per_series_aligner   = string
          cross_series_reducer = string
          group_by_fields     = list(string)
        }))
      }))
    }))
    notification_channels = optional(list(string), [])
    enabled               = optional(bool, true)
    severity              = optional(string, "WARNING")
  }))
  default = {}
}
