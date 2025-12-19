# Regional Cloud Functions Module

This module deploys Cloud Functions (2nd gen) for serverless event-driven applications.

## Features

- Cloud Functions 2nd generation
- HTTP and event triggers
- Environment variables and secrets
- VPC connector integration
- Auto-scaling configuration
- Service account integration
- Build configurations

## Usage

### HTTP Function

```hcl
module "http_function" {
  source = "../../modules/regional/cloud-functions"
  
  project_id = var.project_id
  region     = "asia-south1"
  
  function_name = "my-http-function"
  runtime       = "python311"
  entry_point   = "main"
  
  source_dir = "./function-source"
  
  # HTTP trigger
  trigger_http = true
  
  # Environment variables
  env_vars = {
    API_KEY = "your-api-key"
  }
  
  # Resource limits
  available_memory = "256M"
  available_cpu    = "1"
  
  # Auto-scaling
  min_instances = 0
  max_instances = 10
}
```

### Event-driven Function

```hcl
module "pubsub_function" {
  source = "../../modules/regional/cloud-functions"
  
  project_id = var.project_id
  region     = "asia-south1"
  
  function_name = "my-pubsub-function"
  runtime       = "nodejs20"
  entry_point   = "processPubSubMessage"
  
  source_dir = "./function-source"
  
  # Pub/Sub trigger
  trigger_event_type = "google.cloud.pubsub.topic.v1.messagePublished"
  trigger_pubsub_topic = "projects/my-project/topics/my-topic"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| region | GCP Region | string | - | yes |
| function_name | Name of the function | string | - | yes |
| runtime | Runtime (python311, nodejs20, etc) | string | - | yes |
| entry_point | Function entry point | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| function_uri | Function HTTP URI |
| function_name | Function name |
