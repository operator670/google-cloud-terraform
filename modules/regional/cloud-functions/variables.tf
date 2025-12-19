variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for the function"
  type        = string
}

variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
}

variable "description" {
  description = "Description of the function"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Runtime for the function (e.g., python311, nodejs20, go121)"
  type        = string
}

variable "entry_point" {
  description = "Entry point function name"
  type        = string
}

variable "source_dir" {
  description = "Directory containing the function source code"
  type        = string
  default     = null
}

variable "source_archive_bucket" {
  description = "GCS bucket containing the function source archive"
  type        = string
  default     = null
}

variable "source_archive_object" {
  description = "GCS object containing the function source archive"
  type        = string
  default     = null
}

variable "available_memory" {
  description = "Available memory (e.g., 256M, 512M, 1G)"
  type        = string
  default     = "256M"
}

variable "available_cpu" {
  description = "Available CPU (e.g., 0.5, 1, 2)"
  type        = string
  default     = "1"
}

variable "timeout_seconds" {
  description = "Function timeout in seconds"
  type        = number
  default     = 60
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 100
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instance_request_concurrency" {
  description = "Max concurrent requests per instance"
  type        = number
  default     = 1
}

variable "env_vars" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

variable "secret_env_vars" {
  description = "Environment variables from Secret Manager"
  type = list(object({
    key        = string
    project_id = optional(string)
    secret     = string
    version    = optional(string, "latest")
  }))
  default = []
}

variable "trigger_http" {
  description = "Enable HTTP trigger"
  type        = bool
  default     = false
}

variable "ingress_settings" {
  description = "Ingress settings (ALLOW_ALL, ALLOW_INTERNAL_ONLY, ALLOW_INTERNAL_AND_GCLB)"
  type        = string
  default     = "ALLOW_ALL"
}

variable "trigger_event_type" {
  description = "Event trigger type (e.g., google.cloud.pubsub.topic.v1.messagePublished)"
  type        = string
  default     = null
}

variable "trigger_pubsub_topic" {
  description = "Pub/Sub topic for event trigger"
  type        = string
  default     = null
}

variable "trigger_event_filters" {
  description = "Event filters for trigger"
  type = list(object({
    attribute = string
    value     = string
    operator  = optional(string)
  }))
  default = []
}

variable "trigger_retry_policy" {
  description = "Retry policy (RETRY_POLICY_RETRY or RETRY_POLICY_DO_NOT_RETRY)"
  type        = string
  default     = "RETRY_POLICY_RETRY"
}

variable "vpc_connector" {
  description = "VPC connector for VPC access"
  type        = string
  default     = null
}

variable "vpc_connector_egress_settings" {
  description = "VPC egress settings (PRIVATE_RANGES_ONLY, ALL_TRAFFIC)"
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
  default     = null
}

variable "build_environment_variables" {
  description = "Build-time environment variables"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply to the function"
  type        = map(string)
  default     = {}
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated invocations"
  type        = bool
  default     = false
}
