output "vpc_id" {
  value = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
}

output "app_nodes_id_list" {
  value = module.app_nodes.node_id
}

output "media_nodes_id_list" {
  value = module.media_nodes.node_id
}

output "app_nodes_private_ips" {
  value = module.app_nodes.node_private_dns
}

output "media_nodes_private_ips" {
  value = module.media_nodes.node_private_dns
}

output "ssh_private_key" {
  value     = join("", module.ssh_key.*.key_value)
  sensitive = true
}

output "bastion_public_dns" {
  value = join(", ", module.bastion.*.bastion_public_dns)

}

output "private_sn_ids" {
  value = module.subnets.*.private_sn_ids
}

output "public_sn_id" {
  value = module.subnets.*.public_sn_id

}

