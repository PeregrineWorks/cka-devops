locals {
  boot_image            = "debian-cloud/debian-12"
  disk_type             = "pd-standard" # TODO[research] - does etcd require fast read/writes?
  data_disk_device_name = "data"
}

#* ====================================================================
#* === Compute Disk and Compute Instance
#* ====================================================================

resource "google_compute_disk" "data" {
  name = "${var.name}-data"
  zone = var.zone
  type = local.disk_type
  size = var.data_disk_size_gb
}

resource "google_compute_instance" "k8s_cluster" {
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.tags

  boot_disk {
    initialize_params {
      image = local.boot_image
      type  = local.disk_type
      size  = var.boot_disk_size_gb
    }
  }

  attached_disk {
    source      = google_compute_disk.data.id
    device_name = local.data_disk_device_name
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
