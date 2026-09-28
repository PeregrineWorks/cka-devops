terraform {
  required_version = ">= 1.15"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }

  backend "gcs" {
    bucket = "harsh-cka-devops-terraform-dev-tfstate"
    prefix = "dev/database"
  }
}

provider "google" {
  project                     = var.project_id
  region                      = var.default_region
  impersonate_service_account = var.database_sa
}
