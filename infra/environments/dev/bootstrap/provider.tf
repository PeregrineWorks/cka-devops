terraform {
  required_version = ">= 1.15"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }

  backend "gcs" {
    bucket = "harsh-cka-devops-terraform-dev-tfstate"
    prefix = "bootstrap"
  }
}

# Runs with your own credentials. This is the only stack that uses them.
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
