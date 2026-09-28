output "instance" {
  value = google_sql_database_instance.postgres.name
}

output "private_ip" {
  value = google_sql_database_instance.postgres.private_ip_address
}

output "database" {
  value = google_sql_database.webshop.name
}

output "app_user" {
  value = google_sql_user.app.name
}