variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "log_sinks" {
  description = "Map of log sinks to create"
  type = map(object({
    name                 = string
    destination          = string
    filter               = optional(string, "")
    description          = optional(string, "")
    disabled             = optional(bool, false)
    unique_writer_identity = optional(bool, true)
  }))
  default = {}
}
