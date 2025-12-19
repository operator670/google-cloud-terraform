# Cloud Armor Security Policy
resource "google_compute_security_policy" "policy" {
  name        = var.policy_name
  project     = var.project_id
  description = var.description

  # Adaptive Protection
  dynamic "adaptive_protection_config" {
    for_each = var.adaptive_protection_auto_deploy ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable          = true
        rule_visibility = "STANDARD"
      }
    }
  }

  # Advanced Options
  advanced_options_config {
    json_parsing = var.json_parsing
    log_level    = var.log_level
  }

  # Custom Security Rules
  dynamic "rule" {
    for_each = var.security_rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      preview     = rule.value.preview

      match {
        expr {
          expression = rule.value.match.expr != null ? rule.value.match.expr : null
        }

        dynamic "versioned_expr" {
          for_each = rule.value.match.versioned_expr != null ? [rule.value.match.versioned_expr] : []
          content {
            expression = versioned_expr.value
          }
        }

        dynamic "config" {
          for_each = rule.value.match.src_ip_ranges != null ? [1] : []
          content {
            src_ip_ranges = rule.value.match.src_ip_ranges
          }
        }
      }

      # Rate Limit Options
      dynamic "rate_limit_options" {
        for_each = rule.value.rate_limit_options != null ? [rule.value.rate_limit_options] : []
        content {
          conform_action   = rate_limit_options.value.conform_action
          exceed_action    = rate_limit_options.value.exceed_action
          enforce_on_key   = rate_limit_options.value.enforce_on_key
          ban_duration_sec = rate_limit_options.value.ban_duration_sec

          rate_limit_threshold {
            count        = rate_limit_options.value.rate_limit_threshold.count
            interval_sec = rate_limit_options.value.rate_limit_threshold.interval_sec
          }
        }
      }

      # Header Action
      dynamic "header_action" {
        for_each = rule.value.header_action != null ? [rule.value.header_action] : []
        content {
          dynamic "request_headers_to_adds" {
            for_each = header_action.value.request_headers_to_adds
            content {
              header_name  = request_headers_to_adds.value.header_name
              header_value = request_headers_to_adds.value.header_value
            }
          }
        }
      }

      # Redirect Options
      dynamic "redirect_options" {
        for_each = rule.value.redirect_options != null ? [rule.value.redirect_options] : []
        content {
          type   = redirect_options.value.type
          target = redirect_options.value.target
        }
      }
    }
  }

  # Pre-configured WAF Rules
  dynamic "rule" {
    for_each = var.preconfigured_waf_rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      preview     = rule.value.preview

      match {
        expr {
          expression = "evaluatePreconfiguredWaf('${rule.value.target_rule_set}', {'sensitivity': ${rule.value.sensitivity_level}})"
        }
      }
    }
  }

  # Default Rule
  rule {
    action   = var.default_rule_action
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule"
  }
}
