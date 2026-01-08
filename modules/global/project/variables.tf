variable "name" {
  description = "The display name of the project."
  type        = string
}

variable "project_id" {
  description = "The project ID. Must be unique."
  type        = string
}

variable "folder_id" {
  description = "The numeric ID of the folder this project should be created under."
  type        = string
  default     = null
}

variable "org_id" {
  description = "The numeric ID of the organization this project should be created under."
  type        = string
  default     = null
}

variable "billing_account" {
  description = "The billing account ID to associate with the project."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to the project."
  type        = map(string)
  default     = {}
}

variable "enable_lien" {
  description = "Whether to create a lien on the project to prevent deletion."
  type        = bool
  default     = true
}

variable "is_shared_vpc_host" {
  description = "Whether this project should be a Shared VPC Host."
  type        = bool
  default     = false
}

variable "shared_vpc_host_project_id" {
  description = "The ID of the Shared VPC Host project to attach this project to (if it is a service project)."
  type        = string
  default     = null
}

variable "deletion_policy" {
  description = "The deletion policy for the project. Can be 'PREVENT' (default) or 'DELETE'."
  type        = string
  default     = "PREVENT"
}
