resource "google_project" "main" {
  name            = var.name
  project_id      = var.project_id
  folder_id       = var.folder_id
  org_id          = var.org_id
  billing_account = var.billing_account
  labels          = var.labels
  deletion_policy = var.deletion_policy
}

resource "google_resource_manager_lien" "main" {
  count        = var.enable_lien ? 1 : 0
  parent       = "projects/${google_project.main.number}"
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "terraform-landing-zone"
  reason       = "Landing Zone project '${var.name}' protected by lien."
}

# Enable Compute API (required for Shared VPC)
# Only attempt if billing is enabled
resource "google_project_service" "compute" {
  count   = (var.billing_account != null && (var.is_shared_vpc_host || var.shared_vpc_host_project_id != null)) ? 1 : 0
  project = google_project.main.project_id
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

# Shared VPC Host Enablement
# Only attempt if billing is enabled
resource "google_compute_shared_vpc_host_project" "host" {
  count      = (var.billing_account != null && var.is_shared_vpc_host) ? 1 : 0
  project    = google_project.main.project_id
  depends_on = [google_project_service.compute]
}

# Shared VPC Service Attachment
# Only attempt if billing is enabled
resource "google_compute_shared_vpc_service_project" "service" {
  count           = (var.billing_account != null && var.shared_vpc_host_project_id != null) ? 1 : 0
  host_project    = var.shared_vpc_host_project_id
  service_project = google_project.main.project_id
  depends_on      = [google_project_service.compute]
}
