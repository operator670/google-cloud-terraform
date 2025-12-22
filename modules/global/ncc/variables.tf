variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "hub_name" {
  description = "Name of the NCC Hub"
  type        = string
}

variable "hub_description" {
  description = "Description of the NCC Hub"
  type        = string
  default     = ""
}

variable "vpc_spokes" {
  description = "Map of VPC keys to their self_links to attach as spokes"
  type        = map(string)
  default     = {}
}
