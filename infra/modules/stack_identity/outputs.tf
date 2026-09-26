output "email" {
  value = google_service_account.terraform.email
}

output "member" {
  value = "serviceAccount:${google_service_account.terraform.email}"
}
