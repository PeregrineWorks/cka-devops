terraform {
  required_version = ">= 1.15"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }

  backend "gcs" {
    prefix = "dev/networking"
  }
}

provider "google" {
  project                     = var.project_id
  region                      = var.default_region
  impersonate_service_account = "${var.environment}-networking-terraform@${var.project_id}.iam.gserviceaccount.com"
}
