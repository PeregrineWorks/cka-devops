output "network_id" {
  value = google_compute_network.vpc.id
}

output "nodes_subnetwork_id" {
  value = google_compute_subnetwork.nodes.id
}

output "k8s_node_tag" {
  value = local.k8s_node_tag
}

output "k8s_controlplane_tag" {
  value = local.k8s_controlplane_tag
}
