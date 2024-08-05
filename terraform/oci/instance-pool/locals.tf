locals {
  num_of_subnets          = length(var.subnet_cidr_block_list)
  num_of_instance_pools   = var.media_num_of_instances == 0 ? 0 : (var.media_num_of_instances == 1 ? 1 : local.num_of_subnets)
  base_instances_per_pool = var.media_num_of_instances == 0 ? 0 : floor(var.media_num_of_instances / local.num_of_instance_pools)
  extra_instances         = var.media_num_of_instances % local.num_of_instance_pools

  instances_per_pool_list = [
    for i in range(local.num_of_instance_pools) :
    local.base_instances_per_pool + (i < local.extra_instances ? 1 : 0)
  ]

  num_of_pgs               = var.media_use_placement_group || var.app_use_placement_group ? 1 : 0
  media_cluster_pg_or_null = var.media_use_placement_group ? oci_cluster_placement_groups_cluster_placement_group.vlz_cluster_pg[0].id : null
  app_cluster_pg_or_null   = var.app_use_placement_group ? oci_cluster_placement_groups_cluster_placement_group.vlz_cluster_pg[0].id : null
  secondary_vnic_config    = (length(var.subnet_cidr_block_list) > 1 && var.app_num_of_instances > 0) ? 1 : 0
  secondary_private_ip     = length(var.subnet_cidr_block_list) > 1 && length(data.oci_core_private_ips.app_vnic2_ip) > 0 ? data.oci_core_private_ips.app_vnic2_ip[0].private_ips[0].ip_address : null
  secondary_mac_address    = length(var.subnet_cidr_block_list) > 1 && length(data.oci_core_vnic.app_vnic2_id) > 0 ? data.oci_core_vnic.app_vnic2_id[0].mac_address : null
  secondary_vlan_id        = length(var.subnet_cidr_block_list) > 1 && length(data.oci_core_vnic_attachments.app_vnic2_attachments) > 0 ? lookup(data.oci_core_vnic_attachments.app_vnic2_attachments[0].vnic_attachments[0], "vlan_tag") : null

  fault_domains = length(var.fault_domains) > 0 ? var.fault_domains : null
}