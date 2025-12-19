# Secret Manager Secrets
resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.value.secret_id
  labels    = each.value.labels

  replication {
    dynamic "auto" {
      for_each = each.value.replication_policy.automatic ? [1] : []
      content {}
    }

    dynamic "user_managed" {
      for_each = each.value.replication_policy.user_managed != null ? [1] : []
      content {
        dynamic "replicas" {
          for_each = each.value.replication_policy.user_managed.replicas
          content {
            location = replicas.value.location
          }
        }
      }
    }
  }
}

# Secret Versions
resource "google_secret_manager_secret_version" "versions" {
  for_each = {
    for pair in flatten([
      for secret_key, secret in var.secrets : [
        for version in secret.versions : {
          secret_key = secret_key
          version_id = version.version_id
          data       = version.secret_data
          enabled    = version.enabled
        }
      ]
    ]) : "${pair.secret_key}-${pair.version_id}" => pair
  }

  secret      = google_secret_manager_secret.secrets[each.value.secret_key].id
  secret_data = each.value.data
  enabled     = each.value.enabled
}

# IAM Bindings for Secrets
resource "google_secret_manager_secret_iam_member" "bindings" {
  for_each = {
    for pair in flatten([
      for secret_key, secret in var.secrets : [
        for binding in secret.iam_bindings : [
          for member in binding.members : {
            secret_key = secret_key
            role       = binding.role
            member     = member
          }
        ]
      ]
    ]) : "${pair.secret_key}-${pair.role}-${pair.member}" => pair
  }

  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_key].secret_id
  role      = each.value.role
  member    = each.value.member
}
