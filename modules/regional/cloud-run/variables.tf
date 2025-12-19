variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for Cloud Run service"
  type        = string
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "image" {
  description = "Container image URL"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit (e.g., 1000m for 1 CPU)"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit (e.g., 512Mi, 1Gi)"
  type        = string
  default     = "512Mi"
}

variable "timeout_seconds" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instance_request_concurrency" {
  description = "Maximum concurrent requests per instance"
  type        = number
  default     = 80
}

variable "port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "env_vars" {
  description = "Environment variables"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "env_secrets" {
  description = "Environment variables from Secret Manager"
  type = list(object({
    name   = string
    secret = string
    version = optional(string, "latest")
  }))
  default = []
}

variable "ingress" {
  description = "Ingress settings (all, internal, internal-and-cloud-load-balancing)"
  type        = string
  default     = "all"
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated access"
  type        = bool
  default     = false
}

variable "vpc_connector_name" {
  description = "VPC connector name for VPC access"
  type        = string
  default     = null
}

variable "vpc_egress" {
  description = "VPC egress setting (all-traffic, private-ranges-only)"
  type        = string
  default     = "private-ranges-only"
}

variable "service_account_email" {
  description = "Service account email for the service"
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to the service"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations for the service"
  type        = map(string)
  default     = {}
}

variable "cloudsql_instances" {
  description = "Cloud SQL instance connection names"
  type        = list(string)
  default     = []
}
