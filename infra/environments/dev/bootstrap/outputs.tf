output "networking_terraform_sa" {
  value = module.networking_identity.email
}

output "database_terraform_sa" {
  value = module.database_identity.email
}

output "vms_terraform_sa" {
  value = module.vms_identity.email
}

output "db_pwd_secret" {
  value = google_secret_manager_secret.db_pwd.secret_id
}
