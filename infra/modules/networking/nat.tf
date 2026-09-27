#* ====================================================================
#* === Outbound CloudNAT
#* ====================================================================

resource "google_compute_router" "nat" {
  name    = "${var.environment}-nat-router"
  network = google_compute_network.vpc.id
  region  = var.default_region
}

resource "google_compute_router_nat" "nodes" {
  name                               = "${var.environment}-nodes-nat"
  router                             = google_compute_router.nat.name
  region                             = var.default_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.nodes.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
