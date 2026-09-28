output "zone_dns_name" {
  value = google_dns_managed_zone.internal.dns_name
}

output "kube_apiserver_name" {
  value = google_dns_record_set.kube_apiserver.name
}

output "postgres_name" {
  value = google_dns_record_set.postgres.name
}