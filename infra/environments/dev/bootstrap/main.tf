locals {
  apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "storage.googleapis.com",

    "iap.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

resource "google_project_service" "apis" {
  for_each           = toset(local.apis)
  service            = each.value
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_storage_bucket" "tf_state" {
  name                        = var.bucket_prefix
  project                     = var.project_id
  location                    = var.default_region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  # Delete older versions (newest version is preserved) after a week
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions         = 1
      days_since_noncurrent_time = 7
      with_state                 = "ARCHIVED"
    }
  }

  depends_on = [google_project_service.apis]
}
