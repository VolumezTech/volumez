output "vpc_id" {
    value = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
}

output "app_nodes_id_list" {
    value = module.app_nodes.node_id
}

output "media_nodes_id_list" {
    value = module.media_nodes.node_id
}

output "app_nodes_public_dns" {
    value = module.app_nodes.node_public_dns
}

output "media_nodes_public_dns" {
    value = module.media_nodes.node_public_dns
}

output ssh_key_name {
    value = module.ssh_key.key_name
}

output "ssh_key_value" {
    value = module.ssh_key.key_value
    sensitive = true
}