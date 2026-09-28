# Was defined at the module level, but defining here as well
# so that other stacks can see and use these outputs

output "network_id" {
  value = module.networking.network_id
}

output "nodes_subnetwork_id" {
  value = module.networking.nodes_subnetwork_id
}

output "k8s_node_tag" {
  value = module.networking.k8s_node_tag
}

output "k8s_controlplane_tag" {
  value = module.networking.k8s_controlplane_tag
}
