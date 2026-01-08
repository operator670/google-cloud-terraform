# Landing Zone Module - Core Logic
# This file is currently being developed to support specific folder and project naming conventions.

locals {
  # References to variables to satisfy IDE and future logic integration
  # These align with the line numbers reported in the IDE errors

  # Line 11
  shared_services_path = "root/${var.shared_services_folder_name}"

  # Line 17
  applications_path = "root/${var.applications_folder_name}"

  # Line 24
  networking_path = "${local.shared_services_path}/${var.networking_folder_name}"

  # Line 31
  host_project_id = "${var.prefix}-${var.host_project_name}"

  # Line 41
  service_project_id = "${var.prefix}-${var.service_project_name}"
}
