locals {
  subnetwork = "projects/${var.project_id}/regions/${var.default_region}/subnetworks/${var.environment}-nodes"

  k8s_node_tag         = "k8s-node"
  k8s_controlplane_tag = "k8s-controlplane"
  k8s_worker_tag       = "k8s-worker"

  zone              = "${var.default_region}-a"
  node_machine_type = "e2-medium"
  boot_disk_size_gb = 30
  data_disk_size_gb = 20
}

#* ====================================================================
#* === Control Plane and worker nodes
#* ====================================================================

module "controlplane" {
  source                = "../../../modules/vm"
  name                  = "${var.environment}-cp-1"
  zone                  = local.zone
  machine_type          = local.node_machine_type
  subnetwork            = local.subnetwork
  service_account_email = var.vm_runtime_service_account
  tags                  = [local.k8s_node_tag, local.k8s_controlplane_tag]
  boot_disk_size_gb     = local.boot_disk_size_gb
  data_disk_size_gb     = local.data_disk_size_gb
}

module "worker_1" {
  source                = "../../../modules/vm"
  name                  = "${var.environment}-worker-1"
  zone                  = local.zone
  machine_type          = local.node_machine_type
  subnetwork            = local.subnetwork
  service_account_email = var.vm_runtime_service_account
  tags                  = [local.k8s_node_tag, local.k8s_worker_tag]
  boot_disk_size_gb     = local.boot_disk_size_gb
  data_disk_size_gb     = local.data_disk_size_gb
}

module "worker_2" {
  source                = "../../../modules/vm"
  name                  = "${var.environment}-worker-2"
  zone                  = local.zone
  machine_type          = local.node_machine_type
  subnetwork            = local.subnetwork
  service_account_email = var.vm_runtime_service_account
  tags                  = [local.k8s_node_tag, local.k8s_worker_tag]
  boot_disk_size_gb     = local.boot_disk_size_gb
  data_disk_size_gb     = local.data_disk_size_gb
}

module "worker_3" {
  source                = "../../../modules/vm"
  name                  = "${var.environment}-worker-3"
  zone                  = local.zone
  machine_type          = local.node_machine_type
  subnetwork            = local.subnetwork
  service_account_email = var.vm_runtime_service_account
  tags                  = [local.k8s_node_tag, local.k8s_worker_tag]
  boot_disk_size_gb     = local.boot_disk_size_gb
  data_disk_size_gb     = local.data_disk_size_gb
}
