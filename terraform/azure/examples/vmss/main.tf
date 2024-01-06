provider "azurerm" {
  features {}
}

data "azurerm_ssh_public_key" "this" {
  name                = var.ssh_key_name
  resource_group_name = var.ssh_rg_name
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

###############
### Network ###
###############

module "resource-group" {
  source = "../../../modules/resource-group"

  resource_prefix         = var.resource_prefix
  resource_group_location = var.resource_group_location
  address_space           = var.address_space
  address_prefixes        = var.address_prefixes
  random_string           = random_string.this.result
}

resource "azurerm_proximity_placement_group" "this" {
  name                = "${var.resource_prefix}-pg"
  location            = module.resource-group.rg_location
  resource_group_name = module.resource-group.rg_name

  tags = {
    environment = "Volumez"
  }
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "this" {
  name                = "${var.resource_prefix}-vmss"
  resource_group_name = module.resource-group.rg_name
  location            = module.resource-group.rg_location
  sku_name            = var.media_node_size
  instances           = var.num_of_media_nodes

  zones                        = ["1"]
  proximity_placement_group_id = azurerm_proximity_placement_group.this[0].id
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
        public_key = data.azurerm_ssh_public_key.this.public_key
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
    name    = "vlz-nic"
    primary = true
    enable_accelerated_networking = true

    ip_configuration {
      name      = "vlz-internal"
      primary   = true
      subnet_id = module.resource-group.subnet_id
      
      public_ip_address {
        name                    = "vlz-pub"
        domain_name_label       = "vlz-pub"
        idle_timeout_in_minutes = 30
      }
    }
  }
}
