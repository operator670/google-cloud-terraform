variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "service_accounts" {
  description = "List of service accounts to create"
  type = list(object({
    account_id   = string
    display_name = string
    description  = optional(string, "")
  }))
  default = []
}

variable "project_iam_bindings" {
  description = "Project-level IAM bindings"
  type = list(object({
    role    = string
    members = list(string)
  }))
  default = []
}

variable "service_account_iam_bindings" {
  description = "Service account-level IAM bindings"
  type = list(object({
    service_account_id = string
    role               = string
    members            = list(string)
  }))
  default = []
}

variable "workload_identity_bindings" {
  description = "Workload Identity bindings for GKE"
  type = list(object({
    service_account_id = string
    namespace          = string
    ksa_name           = string
  }))
  default = []
}

variable "create_keys" {
  description = "Create service account keys (not recommended for production)"
  type        = bool
  default     = false
}
