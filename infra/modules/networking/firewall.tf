locals {
  k8s_node_tag         = "k8s-node"
  k8s_controlplane_tag = "k8s-controlplane"
  iap_source_range     = "35.235.240.0/20"
}

#* ====================================================================
#* === FIREWALL
#* ====================================================================

# Thinking ahead here - would be easy if I could ssh into the nodes...
# apparently "gcloud compute ssh --tunnel-through-iap" is a thing...
# going to provision nodes such that they have no public IP!

resource "google_compute_firewall" "iap_ssh" {
  name          = "${var.environment}-allow-iap-ssh"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = [local.iap_source_range]
  target_tags   = [local.k8s_node_tag]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# K8s apiserver uses port 6443
resource "google_compute_firewall" "iap_kube_apiserver" {
  name          = "${var.environment}-allow-iap-kube-apiserver"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = [local.iap_source_range]
  target_tags   = [local.k8s_controlplane_tag]

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
}

# TODO[feat] : How to let nodes talk to each other? 
# Haven't chosen a CNI yet - and I assume differente routing protocols?
# Going to have to revisit this once a CNI is chosen...
# Enabling all protocols and ports for the timebeing...

resource "google_compute_firewall" "k8s_internal" {
  name        = "${var.environment}-allow-k8s-internal"
  network     = google_compute_network.vpc.id
  direction   = "INGRESS"
  source_tags = [local.k8s_node_tag]
  target_tags = [local.k8s_node_tag]

  allow {
    protocol = "all"
  }
}