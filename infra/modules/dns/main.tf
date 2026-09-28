locals {
  zone = "${var.default_region}-a"

  dns_name   = "${var.environment}.cka.internal."
  record_ttl = 300
}

data "google_compute_network" "vpc" {
  name = "${var.environment}-vpc"
}

data "google_compute_instance" "controlplane" {
  name = "${var.environment}-cp-1"
  zone = local.zone
}

data "google_compute_instance" "worker_1" {
  name = "${var.environment}-worker-1"
  zone = local.zone
}

data "google_compute_instance" "worker_2" {
  name = "${var.environment}-worker-2"
  zone = local.zone
}

data "google_compute_instance" "worker_3" {
  name = "${var.environment}-worker-3"
  zone = local.zone
}

data "google_sql_database_instance" "postgres" {
  name = "${var.environment}-postgres"
}

#* ====================================================================
#* === DNS Records
#* ====================================================================

resource "google_dns_managed_zone" "internal" {
  name       = "${var.environment}-internal"
  dns_name   = local.dns_name
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.vpc.id
    }
  }
}

resource "google_dns_record_set" "controlplane" {
  managed_zone = google_dns_managed_zone.internal.name
  name         = "cp-1.${local.dns_name}"
  type         = "A"
  ttl          = local.record_ttl
  rrdatas      = [data.google_compute_instance.controlplane.network_interface[0].network_ip]
}

resource "google_dns_record_set" "kube_apiserver" {
  managed_zone = google_dns_managed_zone.internal.name
  name         = "k8s-api.${local.dns_name}"
  type         = "CNAME"
  ttl          = local.record_ttl
  rrdatas      = [google_dns_record_set.controlplane.name]
}

resource "google_dns_record_set" "worker_1" {
  managed_zone = google_dns_managed_zone.internal.name
  name         = "worker-1.${local.dns_name}"
  type         = "A"
  ttl          = local.record_ttl
  rrdatas      = [data.google_compute_instance.worker_1.network_interface[0].network_ip]
}

resource "google_dns_record_set" "worker_2" {
  managed_zone = google_dns_managed_zone.internal.name
  name         = "worker-2.${local.dns_name}"
  type         = "A"
  ttl          = local.record_ttl
  rrdatas      = [data.google_compute_instance.worker_2.network_interface[0].network_ip]
}

resource "google_dns_record_set" "worker_3" {
  managed_zone = google_dns_managed_zone.internal.name
  name         = "worker-3.${local.dns_name}"
  type         = "A"
  ttl          = local.record_ttl
  rrdatas      = [data.google_compute_instance.worker_3.network_interface[0].network_ip]
}

resource "google_dns_record_set" "postgres" {
  managed_zone = google_dns_managed_zone.internal.name
  name         = "postgres.${local.dns_name}"
  type         = "A"
  ttl          = local.record_ttl
  rrdatas      = [data.google_sql_database_instance.postgres.private_ip_address]
}