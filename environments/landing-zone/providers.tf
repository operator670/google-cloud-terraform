terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.14.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend configuration - Initialize with: 
  # terraform init -backend-config=../../backend-configs/landing-zone.tfvars
  backend "gcs" {}
}

provider "google" {
  # Note: parent_id and other vars are used in the landing_zone module
  # But the provider itself needs a project to function for some resources
  # However, for organization-level resource creation, it often uses the caller's credentials
}
