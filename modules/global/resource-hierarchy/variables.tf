variable "display_name" {
  description = "The folder's display name."
  type        = string
}

variable "parent" {
  description = "The resource name of the parent Folder or Organization. Must be of the form organizations/org_id or folders/folder_id."
  type        = string
}
