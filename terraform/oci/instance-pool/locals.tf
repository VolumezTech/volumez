locals {
  media_num_of_instances = length(var.subnet_cidr_block_list) > 1 ? var.media_num_of_instances / length(var.subnet_cidr_block_list) : var.media_num_of_instances
  secondary_vnic_config = length(var.subnet_cidr_block_list) > 1 ? 1 : 0

  secondary_private_ip = length(var.subnet_cidr_block_list) > 1 ? data.oci_core_private_ips.app_vnic2_ip[0].private_ips[0].ip_address : null
  secondary_mac_address = length(var.subnet_cidr_block_list) > 1 ? data.oci_core_vnic.app_vnic2_id[0].mac_address : null
  secondary_vlan_id = length(var.subnet_cidr_block_list) > 1 ? lookup(data.oci_core_vnic_attachments.app_vnic2_attachments[0].vnic_attachments[0], "vlan_tag") : null
}