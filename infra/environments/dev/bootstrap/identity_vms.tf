module "vms_identity" {
  source       = "../../../modules/stack_identity"
  project_id   = var.project_id
  environment  = var.environment
  stack        = "vms"
  state_bucket = google_storage_bucket.tf_state.name
  operator     = var.operator

  project_roles = [
    "roles/compute.instanceAdmin.v1"
  ]

  depends_on = [google_project_service.apis]
}

resource "google_service_account" "vm_runtime" {
  project      = var.project_id
  account_id   = "${var.environment}-vm-runtime"
  display_name = "${var.environment}-vm-runtime"
  description  = "Identity the dev VMs run as."

  depends_on = [google_project_service.apis]
}

resource "google_service_account_iam_member" "vms_terraform_acts_as_vm_runtime" {
  service_account_id = google_service_account.vm_runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = module.vms_identity.member
}

resource "google_project_iam_member" "vm_runtime_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_runtime.email}"
}

resource "google_project_iam_member" "vm_runtime_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.vm_runtime.email}"
}
