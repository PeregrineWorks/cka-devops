output "name" {
  value = google_compute_instance.k8s_cluster.name
}

output "internal_ip" {
  value = google_compute_instance.k8s_cluster.network_interface[0].network_ip
}

output "data_disk" {
  value = google_compute_disk.data.name
}
