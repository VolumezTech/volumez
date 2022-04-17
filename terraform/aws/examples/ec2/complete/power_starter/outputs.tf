output "vpc_id" {
    value = module.vpc.vpc_id
}

output "app_nodes_id_list" {
    value = module.app_nodes.node_id
}

output "media_nodes_id_list" {
    value = module.media_nodes.node_id
}