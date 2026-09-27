locals {
  nodes_subnet_cidr = "10.10.0.0/24"
}

#* ====================================================================
#* === VPC & Nodes' Subnet
#* ====================================================================

resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "nodes" {
  name                     = "${var.environment}-nodes"
  network                  = google_compute_network.vpc.id
  region                   = var.default_region
  ip_cidr_range            = local.nodes_subnet_cidr
  private_ip_google_access = true
}
