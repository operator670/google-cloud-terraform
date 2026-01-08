variable "parent_id" {
  description = "The parent organization ID (organizations/123) or folder ID (folders/123)."
  type        = string
}

variable "billing_account" {
  description = "The billing account ID to associate with all projects."
  type        = string
}

variable "prefix" {
  description = "Prefix for all project IDs (e.g., 'acme')."
  type        = string
}

variable "env_name" {
  description = "Environment name for project IDs (e.g., 'prod', 'staging')."
  type        = string
}
