terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.31.0"
    }
  }
}

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
  security_list_ids   = [oci_core_vcn.vlz_vcn.default_security_list_id, oci_core_security_list.volumez-sl.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vlz_vcn.id
  route_table_id      = oci_core_route_table.vlz_route_table.id
  dhcp_options_id     = oci_core_vcn.vlz_vcn.default_dhcp_options_id
}

### Compute
# Media

resource "oci_core_instance_configuration" "media_instance_configuration" {
  compartment_id = var.tenancy_ocid
  display_name   = "media_instance-${random_string.deploy_id.result}"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.tenancy_ocid
      shape          = var.media_shape

      shape_config {
        memory_in_gbs = var.media_memory_in_gbs
        ocpus         = var.media_num_of_ocpus
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
  }
}

resource "oci_core_instance_pool" "media_instance_pool" {
  for_each = zipmap(range(length(oci_core_subnet.vlz_subnet)), oci_core_subnet.vlz_subnet.*.id)

  compartment_id            = var.tenancy_ocid
  instance_configuration_id = oci_core_instance_configuration.media_instance_configuration.id
  display_name              = format("media-instance-pool-${random_string.deploy_id.result}-%s", each.key)
  placement_configurations {
    availability_domain = data.oci_identity_availability_domain.ad.name
    primary_subnet_id   = each.value
  }
  size = local.media_num_of_instances

  timeouts {
    create = "7m"
  }
}

# Application

resource "oci_core_instance_configuration" "app_instance_configuration" {
  compartment_id = var.tenancy_ocid
  display_name   = "app_instance-${random_string.deploy_id.result}"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.tenancy_ocid
      shape          = var.app_shape

      dynamic "shape_config" {
        for_each = var.app_shape == "BM.Standard.E5.192" ? [] : [1]
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
        display_name = "vlz-second-vnic-${random_string.deploy_id.result}"
      }
    }
  }
}

resource "oci_core_instance_pool" "app_instance_pool" {
  compartment_id            = var.tenancy_ocid
  instance_configuration_id = oci_core_instance_configuration.app_instance_configuration.id
  display_name              = "app-instance-pool-${random_string.deploy_id.result}"
  placement_configurations {
    availability_domain = data.oci_identity_availability_domain.ad.name
    primary_subnet_id   = oci_core_subnet.vlz_subnet[0].id
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
    create = "7m"
  }
}

resource "null_resource" "app_secondary_vnic_coppy_script" {
  count = local.secondary_vnic_config

  depends_on = [ oci_core_instance_pool.app_instance_pool ]
  provisioner "file" {
    source = "${path.module}/cloudinit/secondary_vnic_all_configure.sh"
    destination = "/tmp/secondary_vnic_config.sh"
  }
  connection {
    type        = "ssh"
    host        = data.oci_core_instance.app_instance.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
  }
}

resource "null_resource" "app_secondary_vnic_exec" {
  count = local.secondary_vnic_config

  depends_on = [ null_resource.app_secondary_vnic_coppy_script ]


  provisioner "remote-exec" {
    inline = [
      #"chmod +x /tmp/secondary_vnic_config.sh",
      #"sudo /tmp/secondary_vnic_config.sh -c /tmp/secondary_vnic_config.sh > /tmp/debug.log 2>&1",
      #"sudo /tmp/secondary_vnic_config.sh -c ${lookup(data.oci_core_private_ips.app_vnic2_ip.private_ips[0], "id")} > /tmp/debug.log 2>&1",
      "sudo ip addr add ${data.oci_core_private_ips.app_vnic2_ip[count.index].private_ips[0].ip_address}/24 brd 10.1.21.255 dev ens340np0 metric 100",
      "sudo ip link set dev ens340np0 mtu 9000",
    ]
    connection {
      type        = "ssh"
      host        = data.oci_core_instance.app_instance.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ssh_key.private_key_pem
    }
  }
}