locals {
  private_services_address       = "10.20.0.0"
  private_services_prefix_length = 16
}

#* ====================================================================
#* === Private Services
#* ====================================================================

# Creating a "private service"/peering between the vpc and
# google's network
resource "google_compute_global_address" "private_services" {
  name          = "${var.environment}-private-services"
  network       = google_compute_network.vpc.id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = local.private_services_address
  prefix_length = local.private_services_prefix_length
}

resource "google_service_networking_connection" "private_services" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services.name]
  deletion_policy         = "ABANDON"
}
