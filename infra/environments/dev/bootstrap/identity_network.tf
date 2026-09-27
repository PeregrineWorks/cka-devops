module "network_identity" {
  source       = "../../../modules/stack_identity"
  project_id   = var.project_id
  environment  = var.environment
  module       = "network"
  state_bucket = google_storage_bucket.tf_state.name
  operator     = var.operator

  project_roles = [
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/servicenetworking.networksAdmin",
  ]

  depends_on = [google_project_service.apis]
}
