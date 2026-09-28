output "controlplane_name" {
  value = module.controlplane.name
}

output "controlplane_internal_ip" {
  value = module.controlplane.internal_ip
}

output "worker_internal_ips" {
  value = {
    (module.worker_1.name) = module.worker_1.internal_ip
    (module.worker_2.name) = module.worker_2.internal_ip
    (module.worker_3.name) = module.worker_3.internal_ip
  }
}