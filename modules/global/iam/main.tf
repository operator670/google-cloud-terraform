# Service Accounts
resource "google_service_account" "service_accounts" {
  for_each = { for sa in var.service_accounts : sa.account_id => sa }

  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}

# Project-level IAM Members
# Using locals to flatten the bindings for google_project_iam_member
locals {
  project_members = flatten([
    for binding in var.project_iam_bindings : [
      for member in binding.members : {
        role   = binding.role
        member = member
      }
    ]
  ])

  sa_members = flatten([
    for binding in var.service_account_iam_bindings : [
      for member in binding.members : {
        sa_id  = binding.service_account_id
        role   = binding.role
        member = member
      }
    ]
  ])
}

resource "google_project_iam_member" "project_members" {
  for_each = { for m in local.project_members : "${m.role}-${m.member}" => m }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

# Service Account IAM Members
resource "google_service_account_iam_member" "sa_members" {
  for_each = { for m in local.sa_members : "${m.sa_id}-${m.role}-${m.member}" => m }

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.sa_id}@${var.project_id}.iam.gserviceaccount.com"
  role               = each.value.role
  member             = each.value.member

  depends_on = [google_service_account.service_accounts]
}

# Workload Identity Bindings (for GKE)
resource "google_service_account_iam_member" "workload_identity" {
  for_each = { for idx, binding in var.workload_identity_bindings : "${binding.service_account_id}-${binding.namespace}-${binding.ksa_name}" => binding }

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.service_account_id}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.ksa_name}]"

  depends_on = [google_service_account.service_accounts]
}

# Service Account Keys (Optional - Not recommended for production)
resource "google_service_account_key" "keys" {
  for_each = var.create_keys ? { for sa in var.service_accounts : sa.account_id => sa } : {}

  service_account_id = google_service_account.service_accounts[each.key].name
}
