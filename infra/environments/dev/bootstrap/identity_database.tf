module "database_identity" {
  source       = "../../../modules/stack_identity"
  project_id   = var.project_id
  environment  = var.environment
  stack        = "database"
  state_bucket = google_storage_bucket.tf_state.name
  operator     = var.operator

  project_roles = [
    "roles/cloudsql.admin",
    "roles/compute.networkViewer",
  ]

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret" "db_pwd" {
  project   = var.project_id
  secret_id = "${var.environment}-database-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_iam_member" "database_terraform_manages_versions" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_pwd.secret_id
  role      = "roles/secretmanager.secretVersionManager"
  member    = module.database_identity.member
}

resource "google_secret_manager_secret_iam_member" "database_terraform_views_secret" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_pwd.secret_id
  role      = "roles/secretmanager.viewer"
  member    = module.database_identity.member
}
