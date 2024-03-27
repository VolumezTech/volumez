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

resource "oci_core_vcn" "test_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.tenancy_ocid
  display_name   = "VolumezVcn-${random_string.deploy_id.result}"
  dns_label      = "volumezvcn-${random_string.deploy_id.result}"
}

resource "oci_core_internet_gateway" "test_internet_gateway" {
  compartment_id = var.tenancy_ocid
  display_name   = "VolumezInternetGateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_vcn.test_vcn.id
}

resource "oci_core_route_table" "test_route_table" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.test_vcn.id
  display_name   = "VolumezRouteTable-${random_string.deploy_id.result}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway.id
  }
}

resource "oci_core_subnet" "test_subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = "10.1.20.0/24"
  display_name        = "VolumezSubnet-${random_string.deploy_id.result}"
  dns_label           = "volumezsubnet-${random_string.deploy_id.result}"
  security_list_ids   = [oci_core_vcn.test_vcn.default_security_list_id, oci_core_security_list.volumez-sl.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.test_vcn.id
  route_table_id      = oci_core_route_table.test_route_table.id
  dhcp_options_id     = oci_core_vcn.test_vcn.default_dhcp_options_id
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

      metadata = {
        ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
        user_data           = data.cloudinit_config.operator.rendered
      }
    }
  }
}

resource "oci_core_instance_pool" "media_instance_pool" {
  compartment_id            = var.tenancy_ocid
  instance_configuration_id = oci_core_instance_configuration.media_instance_configuration.id
  display_name              = "media-instance-pool-${random_string.deploy_id.result}"
  placement_configurations {
    availability_domain = data.oci_identity_availability_domain.ad.name
    primary_subnet_id   = oci_core_subnet.test_subnet.id
  }
  size = var.media_num_of_instances

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

      shape_config {
        memory_in_gbs = var.app_memory_in_gbs
        ocpus         = var.app_num_of_ocpus
      }

      source_details {
        source_type             = "image"
        boot_volume_size_in_gbs = 60
        image_id                = var.app_image_id
      }

      metadata = {
        ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
        user_data           = data.cloudinit_config.operator.rendered
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
    primary_subnet_id   = oci_core_subnet.test_subnet.id
  }
  size = var.app_num_of_instances

  timeouts {
    create = "7m"
  }
}
