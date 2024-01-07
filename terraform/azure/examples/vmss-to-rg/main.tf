provider "azurerm" {
  features {}
}
locals {
  use_ppg = length(var.zones) <= 1 ? true : false
}
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

###############
### Network ###
###############

resource "azurerm_orchestrated_virtual_machine_scale_set" "this" {
  name                = "${var.resource_prefix}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku_name            = var.media_node_size
  instances           = var.num_of_media_nodes

  zones                        = var.zones
  proximity_placement_group_id = local.use_ppg ? var.proximity_placement_group_id : null
  platform_fault_domain_count  = var.platform_fault_domain_count

  source_image_reference {
    publisher = var.media_image_publisher
    offer     = var.media_image_offer
    sku       = var.media_image_sku
    version   = var.media_image_version
  }

  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = var.ssh_username

      admin_ssh_key {
        username   = var.ssh_username
        public_key = tls_private_key.ssh_key.public_key_openssh
      }
    }
    custom_data = base64encode(
      <<-EOF
            #!/bin/bash

            echo "deb [arch="$(dpkg --print-architecture)" trusted=yes] https://signup.volumez.com/netapp/ubuntu stable main" | sudo tee  /etc/apt/sources.list.d/vlzconnector.list
            sudo mkdir -p /opt/vlzconnector
            echo -n ${var.vlz_tenant_token} | sudo tee -a /opt/vlzconnector/tenantToken
            sudo apt update
            sudo DEBIAN_FRONTEND=noninteractive apt install -q -y vlzconnector
        EOF
    )
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                          = "vlz-nic"
    primary                       = true
    enable_accelerated_networking = true

    ip_configuration {
      name      = "vlz-internal"
      primary   = true
      subnet_id = var.subnet_id

      public_ip_address {
        name                    = "vlz-pub"
        domain_name_label       = "vlz-pub"
        idle_timeout_in_minutes = 30
      }
    }
  }
}
