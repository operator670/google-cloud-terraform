# Generate random ID for unique bucket name
resource "random_id" "bucket_suffix" {
  count = var.source_dir != null ? 1 : 0
  byte_length = 4
}

# GCS bucket for function source (if source_dir is provided)
resource "google_storage_bucket" "function_source" {
  count = var.source_dir != null ? 1 : 0

  name     = "${var.function_name}-source-${random_id.bucket_suffix[0].hex}"
  project  = var.project_id
  location = var.region

  uniform_bucket_level_access = true
  force_destroy               = true
}

# Archive source directory
data "archive_file" "source" {
  count = var.source_dir != null ? 1 : 0

  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/source.zip"
}

# Upload source archive to GCS
resource "google_storage_bucket_object" "source_archive" {
  count = var.source_dir != null ? 1 : 0

  name   = "source-${data.archive_file.source[0].output_md5}.zip"
  bucket = google_storage_bucket.function_source[0].name
  source = data.archive_file.source[0].output_path
}

# Cloud Function (2nd gen)
resource "google_cloudfunctions2_function" "main" {
  name     = var.function_name
  project  = var.project_id
  location = var.region

  description = var.description
  labels      = var.labels

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = var.source_dir != null ? google_storage_bucket.function_source[0].name : var.source_archive_bucket
        object = var.source_dir != null ? google_storage_bucket_object.source_archive[0].name : var.source_archive_object
      }
    }

    environment_variables = var.build_environment_variables
  }

  service_config {
    max_instance_count               = var.max_instances
    min_instance_count               = var.min_instances
    available_memory                 = var.available_memory
    available_cpu                    = var.available_cpu
    timeout_seconds                  = var.timeout_seconds
    max_instance_request_concurrency = var.max_instance_request_concurrency
    
    environment_variables = var.env_vars

    dynamic "secret_environment_variables" {
      for_each = var.secret_env_vars
      content {
        key        = secret_environment_variables.value.key
        project_id = secret_environment_variables.value.project_id != null ? secret_environment_variables.value.project_id : var.project_id
        secret     = secret_environment_variables.value.secret
        version    = secret_environment_variables.value.version
      }
    }

    ingress_settings = var.ingress_settings
    
    service_account_email = var.service_account_email

    dynamic "vpc_connector" {
      for_each = var.vpc_connector != null ? [1] : []
      content {
        connector = var.vpc_connector
      }
    }

    vpc_connector_egress_settings = var.vpc_connector != null ? var.vpc_connector_egress_settings : null
  }

  # Event trigger configuration
  dynamic "event_trigger" {
    for_each = var.trigger_event_type != null ? [1] : []
    content {
      trigger_region = var.region
      event_type     = var.trigger_event_type
      
      pubsub_topic  = var.trigger_pubsub_topic
      retry_policy  = var.trigger_retry_policy

      dynamic "event_filters" {
        for_each = var.trigger_event_filters
        content {
          attribute = event_filters.value.attribute
          value     = event_filters.value.value
          operator  = event_filters.value.operator
        }
      }
    }
  }
}

# IAM binding for public access (HTTP functions only)
resource "google_cloudfunctions2_function_iam_member" "invoker" {
  count = var.trigger_http && var.allow_unauthenticated ? 1 : 0

  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.main.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
