variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "primary_region" {
  description = "Primary GCP region"
  type        = string
  default     = "asia-south1"
}

variable "customer_name" {
  description = "Customer name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}
