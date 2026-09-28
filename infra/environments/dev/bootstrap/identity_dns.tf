module "dns_identity" {
  source       = "../../../modules/stack_identity"
  project_id   = var.project_id
  environment  = var.environment
  stack        = "dns"
  state_bucket = google_storage_bucket.tf_state.name
  operator     = var.operator

  project_roles = [
    "roles/dns.admin",
    "roles/compute.viewer",
    "roles/cloudsql.viewer",
  ]

  depends_on = [google_project_service.apis]
}
