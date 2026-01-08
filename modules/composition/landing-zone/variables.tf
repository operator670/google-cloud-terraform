variable "parent_id" {
  description = "The parent organization ID (organizations/123) or folder ID (folders/123) where the landing zone will be created."
  type        = string
}

variable "billing_account" {
  description = "The billing account ID to associate with all projects."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix for all project IDs to ensure global uniqueness (e.g., 'acme')."
  type        = string
}

variable "env_name" {
  description = "Environment name to include in project IDs (e.g., 'prod', 'staging')."
  type        = string
}

variable "shared_services_folder_name" {
  description = "Name for the shared services folder."
  type        = string
  default     = "Shared-Services"
}

variable "applications_folder_name" {
  description = "Name for the applications folder."
  type        = string
  default     = "Applications"
}

variable "networking_folder_name" {
  description = "Name for the networking folder."
  type        = string
  default     = "Networking"
}

variable "host_project_name" {
  description = "Name for the host project."
  type        = string
  default     = "host-networking"
}

variable "service_project_name" {
  description = "Name for the service project."
  type        = string
  default     = "service-project"
}

variable "config_file" {
  description = "Path to the YAML configuration file."
  type        = string
}
