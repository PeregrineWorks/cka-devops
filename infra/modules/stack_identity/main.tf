# Idea is that every module gets its own service account
# This way, permissions are scoped using the "least privelege" principle

resource "google_service_account" "terraform" {
  project      = var.gcp_project
  account_id   = "${var.environment}-${var.module}-terraform"
  display_name = "${var.environment}-${var.module}-terraform"
  description  = "Terraform indentity for modules/${var.environment}-${var.module}"
}

resource "google_service_account_iam_member" "operator_impersonates" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.operator
}

# Granting an SA access to the state storage bucket ONLY
# Instead of all buckets in project
resource "google_storage_bucket_iam_member" "state" {
  bucket = var.state_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_project_iam_member" "roles" {
  for_each = toset(var.project_roles)
  role     = each.value
  project  = var.gcp_project
  member   = "serviceAccount:${google_service_account.terraform.email}"
}
