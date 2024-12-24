### Random
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

### SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

### Network
resource "oci_core_vcn" "vlz_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.tenancy_ocid
  display_name   = "VolumezVcn-${random_string.deploy_id.result}"
  dns_label      = "volumezvcn"
}

resource "oci_core_internet_gateway" "vlz_internet_gateway" {
  compartment_id = var.tenancy_ocid
  display_name   = "VolumezInternetGateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_vcn.vlz_vcn.id
}

resource "oci_core_route_table" "vlz_route_table" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vlz_vcn.id
  display_name   = "VolumezRouteTable-${random_string.deploy_id.result}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.vlz_internet_gateway.id
  }
}

resource "oci_core_subnet" "vlz_subnet" {
  count = length(var.subnet_cidr_block_list)

  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.subnet_cidr_block_list[count.index]
  display_name        = "VlzSubnet-${count.index}-${random_string.deploy_id.result}"
  dns_label           = "vlzsubnet${count.index}"
  security_list_ids   = [oci_core_security_list.volumez-sl.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vlz_vcn.id
  route_table_id      = oci_core_route_table.vlz_route_table.id
  dhcp_options_id     = oci_core_vcn.vlz_vcn.default_dhcp_options_id
}

resource "oci_cluster_placement_groups_cluster_placement_group" "vlz_cluster_pg" {
  count = local.num_of_pgs

  availability_domain          = data.oci_identity_availability_domain.ad.name
  cluster_placement_group_type = "STANDARD"
  compartment_id               = var.tenancy_ocid
  description                  = "bla"
  name                         = "cluster_pg-${random_string.deploy_id.result}"
}

### Compute
# Media #
resource "oci_core_instance_configuration" "media_instance_configuration" {
  compartment_id = var.tenancy_ocid
  display_name   = "media_instance-${random_string.deploy_id.result}"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.tenancy_ocid
      shape          = var.media_shape
      cluster_placement_group_id = local.media_cluster_pg_or_null

      dynamic "shape_config" {
        for_each = var.media_ignore_cpu_mem_req ? [] : [1]
        content {
          memory_in_gbs = var.media_memory_in_gbs
          ocpus         = var.media_num_of_ocpus
        }
      }

      source_details {
        source_type             = "image"
        boot_volume_size_in_gbs = 60
        image_id                = var.media_image_id
      }
      launch_options {
        network_type = "VFIO"
      }

      metadata = {
        ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
        user_data           = data.cloudinit_config.operator.rendered
      }
    }
    dynamic "secondary_vnics" {
      for_each = length(var.subnet_cidr_block_list) > 1 ? [1] : []
      content {
        create_vnic_details {
          subnet_id                 = oci_core_subnet.vlz_subnet[1].id
          assign_private_dns_record = true
          assign_public_ip          = true
          display_name              = "vlz-second-vnic-${random_string.deploy_id.result}"
        }
        nic_index = var.media_secondary_vnic_index
        display_name = "vlz-second-vnic-${random_string.deploy_id.result}"
      }
    }
  }
}

resource "oci_core_instance_pool" "media_instance_pool" {
  #for_each = zipmap(range(local.num_of_subnets), oci_core_subnet.vlz_subnet.*.id)
  count = local.num_of_instance_pools

  compartment_id            = var.tenancy_ocid
  instance_configuration_id = oci_core_instance_configuration.media_instance_configuration.id
  display_name              = format("media-instance-pool-${random_string.deploy_id.result}-%s", count.index)
  
  placement_configurations {
    availability_domain = data.oci_identity_availability_domain.ad.name
    primary_subnet_id   = oci_core_subnet.vlz_subnet[count.index].id
    fault_domains       = local.fault_domains
    dynamic "secondary_vnic_subnets" {
      for_each = length(var.subnet_cidr_block_list) > 1 ? [1] : []
      content {
        subnet_id    = oci_core_subnet.vlz_subnet[1].id
        display_name = "vlz-second-vnic-${random_string.deploy_id.result}"
      }
    }
  }
  size = local.instances_per_pool_list[count.index]

  timeouts {
    create = "10m"
  }
}

# Application #
resource "oci_core_instance_configuration" "app_instance_configuration" {
  compartment_id = var.tenancy_ocid
  display_name   = "app_instance-${random_string.deploy_id.result}"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.tenancy_ocid
      shape          = var.app_shape
      cluster_placement_group_id = local.app_cluster_pg_or_null

      dynamic "shape_config" {
        for_each = var.app_ignore_cpu_mem_req ? [] : [1]
        content {
          memory_in_gbs = var.app_memory_in_gbs
          ocpus         = var.app_num_of_ocpus
        }
      }

      source_details {
        source_type             = "image"
        boot_volume_size_in_gbs = 60
        image_id                = var.app_image_id
      }

      create_vnic_details {
        subnet_id                 = oci_core_subnet.vlz_subnet[0].id
        assign_private_dns_record = true
        assign_public_ip          = true
        display_name              = "vlz-prime-vnic-${random_string.deploy_id.result}"
      }

      launch_options {
        network_type = "VFIO"

      }

      metadata = {
        ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
        user_data           = data.cloudinit_config.operator.rendered
      }
    }
    dynamic "secondary_vnics" {
      for_each = length(var.subnet_cidr_block_list) > 1 ? [1] : []
      content {
        create_vnic_details {
          subnet_id                 = oci_core_subnet.vlz_subnet[1].id
          assign_private_dns_record = true
          assign_public_ip          = true
          display_name              = "vlz-second-vnic-${random_string.deploy_id.result}"
        }
        nic_index = var.app_secondary_vnic_index
        display_name = "vlz-second-vnic-${random_string.deploy_id.result}"
      }
    }
  }
}

resource "oci_core_instance_pool" "app_instance_pool" {
  count                     = var.app_num_of_instances > 0 ? var.app_num_of_instances : 0
  compartment_id            = var.tenancy_ocid
  instance_configuration_id = oci_core_instance_configuration.app_instance_configuration.id
  display_name              = "app-instance-pool-${random_string.deploy_id.result}"
  placement_configurations {
    availability_domain = data.oci_identity_availability_domain.ad.name
    primary_subnet_id   = oci_core_subnet.vlz_subnet[0].id
    fault_domains       = local.fault_domains
    dynamic "secondary_vnic_subnets" {
      for_each = length(var.subnet_cidr_block_list) > 1 ? [1] : []
      content {
        subnet_id    = oci_core_subnet.vlz_subnet[1].id
        display_name = "vlz-second-vnic-${random_string.deploy_id.result}"
      }
    }
  }
  size = var.app_num_of_instances

  timeouts {
    create = "10m"
  }
}

resource "null_resource" "app_secondary_vnic_copy_script" {
  count = local.app_secondary_vnic_config

  depends_on = [oci_core_instance_pool.app_instance_pool]
  provisioner "file" {
    source = "${path.module}/cloudinit/secondary_vnic_all_configure.sh"
    destination = "/home/ubuntu/secondary_vnic_config.sh"
  }
  connection {
    type        = "ssh"
    host        = data.oci_core_instance.app_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
  }
}

resource "null_resource" "media_secondary_vnic_copy_script" {
  count = local.media_secondary_vnic_config

  depends_on = [oci_core_instance_pool.media_instance_pool ]
  provisioner "file" {
    source      = "${path.module}/cloudinit/secondary_vnic_all_configure.sh"
    destination = "/home/ubuntu/secondary_vnic_config.sh"
  }
  connection {
    type        = "ssh"
    host        = data.oci_core_instance.media_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
  }
}

resource "null_resource" "app_secondary_vnic_exec" {
  count = local.app_secondary_vnic_config

  depends_on = [oci_core_instance_pool.app_instance_pool, null_resource.app_secondary_vnic_copy_script]

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/secondary_vnic_config.sh",
      #"sudo /home/ubuntu/secondary_vnic_config.sh -c /home/ubuntu/secondary_vnic_config.sh > /home/ubuntu/debug.log 2>&1",
      #"sudo /home/ubuntu/secondary_vnic_config.sh -c ${lookup(data.oci_core_private_ips.app_vnic2_ip.private_ips[0], "id")} > /home/ubuntu//debug.log 2>&1",
      "sudo /home/ubuntu//secondary_vnic_config.sh -c",
      # "sudo ip link set dev ens340np0 mtu 9000",
      # "sudo ip link add link ens340np0 ens340np0.${local.secondary_vlan_id} address ${local.secondary_mac_address} type macvlan",
      # "sudo ip link add link ens340np0.${local.secondary_vlan_id} name ens340np0v${local.secondary_vlan_id} type vlan id ${local.secondary_vlan_id}",
      # "sudo ip addr add ${local.secondary_private_ip}/24 brd 10.1.21.255 dev ens340np0v${local.secondary_vlan_id} metric 100",
      # "sudo ip link set dev ens340np0.${local.secondary_vlan_id} mtu 9000",
      # "sudo ip link set ens340np0.${local.secondary_vlan_id} up"
    ]
    connection {
      type        = "ssh"
      host        = data.oci_core_instance.app_instance[count.index].public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ssh_key.private_key_pem
    }
  }
}

resource "null_resource" "media_secondary_vnic_exec" {
  count = local.media_secondary_vnic_config

  depends_on = [oci_core_instance_pool.media_instance_pool, null_resource.media_secondary_vnic_copy_script]

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/secondary_vnic_config.sh",
      #"sudo /home/ubuntu/secondary_vnic_config.sh -c /home/ubuntu/secondary_vnic_config.sh > /home/ubuntu/debug.log 2>&1",
      #"sudo /home/ubuntu/secondary_vnic_config.sh -c ${lookup(data.oci_core_private_ips.app_vnic2_ip.private_ips[0], "id")} > /home/ubuntu/debug.log 2>&1",
      "sudo /home/ubuntu/secondary_vnic_config.sh -c",
      # "sudo ip link set dev ens340np0 mtu 9000",
      # "sudo ip link add link ens340np0 ens340np0.${local.secondary_vlan_id} address ${local.secondary_mac_address} type macvlan",
      # "sudo ip link add link ens340np0.${local.secondary_vlan_id} name ens340np0v${local.secondary_vlan_id} type vlan id ${local.secondary_vlan_id}",
      # "sudo ip addr add ${local.secondary_private_ip}/24 brd 10.1.21.255 dev ens340np0v${local.secondary_vlan_id} metric 100",
      # "sudo ip link set dev ens340np0.${local.secondary_vlan_id} mtu 9000",
      # "sudo ip link set ens340np0.${local.secondary_vlan_id} up"
    ]
    connection {
      type        = "ssh"
      host        = data.oci_core_instance.media_instance[count.index].public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ssh_key.private_key_pem
    }
  }
}
