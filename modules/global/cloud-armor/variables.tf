variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "policy_name" {
  description = "Name of the Cloud Armor security policy"
  type        = string
}

variable "description" {
  description = "Description of the security policy"
  type        = string
  default     = ""
}

variable "default_rule_action" {
  description = "Default rule action (allow or deny(403))"
  type        = string
  default     = "allow"
  validation {
    condition     = can(regex("^(allow|deny\\(\\d+\\))$", var.default_rule_action))
    error_message = "Default rule action must be 'allow' or 'deny(status_code)'."
  }
}

variable "security_rules" {
  description = "List of custom security rules"
  type = list(object({
    priority    = number
    action      = string
    description = optional(string, "")
    preview     = optional(bool, false)
    match = object({
      expr            = optional(string)
      versioned_expr  = optional(string)
      src_ip_ranges   = optional(list(string))
      expr_options = optional(object({
        recaptcha_options = optional(object({
          action_token_site_keys = optional(list(string))
          session_token_site_keys = optional(list(string))
        }))
      }))
    })
    rate_limit_options = optional(object({
      conform_action = string
      exceed_action  = string
      enforce_on_key = optional(string)
      rate_limit_threshold = object({
        count        = number
        interval_sec = number
      })
      ban_duration_sec = optional(number)
    }))
    header_action = optional(object({
      request_headers_to_adds = list(object({
        header_name  = string
        header_value = string
      }))
    }))
    redirect_options = optional(object({
      type   = string
      target = optional(string)
    }))
  }))
  default = []
}

variable "preconfigured_waf_rules" {
  description = "Pre-configured WAF rules (OWASP, etc.)"
  type = list(object({
    priority         = number
    action           = string
    description      = optional(string, "")
    preview          = optional(bool, false)
    target_rule_set  = string
    sensitivity_level = optional(number, 0)
    rule_ids         = optional(list(string), [])
  }))
  default = []
}

variable "adaptive_protection_auto_deploy" {
  description = "Enable adaptive protection with auto-deployment"
  type        = bool
  default     = false
}

variable "json_parsing" {
  description = "JSON parsing mode (DISABLED, STANDARD)"
  type        = string
  default     = "DISABLED"
  validation {
    condition     = contains(["DISABLED", "STANDARD"], var.json_parsing)
    error_message = "JSON parsing must be DISABLED or STANDARD."
  }
}

variable "log_level" {
  description = "Logging level (NORMAL, VERBOSE)"
  type        = string
  default     = "NORMAL"
  validation {
    condition     = contains(["NORMAL", "VERBOSE"], var.log_level)
    error_message = "Log level must be NORMAL or VERBOSE."
  }
}
