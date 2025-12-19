terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend configuration - customize per customer
  # Initialize with: terraform init -backend-config=../../customers/<customer-name>/backend-config-dev.tfvars
  backend "gcs" {
    # bucket  = "CUSTOMER_NAME-terraform-state"
    # prefix  = "dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.primary_region
}
