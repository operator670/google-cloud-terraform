variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "GCP Region for regional bucket (e.g., asia-south1)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the storage bucket (must be globally unique)"
  type        = string
}

variable "storage_class" {
  description = "Storage class for the bucket"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["STANDARD", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be one of: STANDARD, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "versioning_enabled" {
  description = "Enable object versioning"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow deletion of non-empty bucket"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string)
      with_state            = optional(string)
      matches_storage_class = optional(list(string))
      num_newer_versions    = optional(number)
    })
  }))
  default = []
}

variable "retention_policy" {
  description = "Configuration of the bucket's data retention policy for how long objects in the bucket should be retained."
  type = object({
    is_locked        = bool
    retention_period = number
  })
  default = null
}

variable "encryption_key" {
  description = "Customer-managed encryption key (CMEK) for the bucket"
  type        = string
  default     = null
  sensitive   = true
}

variable "public_access_prevention" {
  description = "Prevent public access to the bucket"
  type        = string
  default     = "enforced"
  validation {
    condition     = contains(["enforced", "inherited"], var.public_access_prevention)
    error_message = "Public access prevention must be 'enforced' or 'inherited'."
  }
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access"
  type        = bool
  default     = true
}

variable "cors_rules" {
  description = "CORS rules for the bucket"
  type = list(object({
    origin          = list(string)
    method          = list(string)
    response_header = list(string)
    max_age_seconds = number
  }))
  default = []
}

variable "iam_bindings" {
  description = "IAM bindings for the bucket"
  type = list(object({
    role    = string
    members = list(string)
  }))
  default = []
}

variable "folders" {
  description = "List of folders to create in the bucket"
  type        = list(string)
  default     = []
}
