
locals {
  platform_fault_domain_count_unf = var.create_fault_domain ? 5 : 1
  platform_fault_domain_count_flex = var.create_fault_domain ? var.platform_fault_domain_count : 1
}

###############
### SSH ###
###############

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  count                        = var.vmss_type == "uniform" ? 1 : 0
  name                         = var.vmss_name
  resource_group_name          = var.resource_group_name
  location                     = var.resource_group_location
  sku                          = var.media_node_type
  instances                    = var.media_node_count
  admin_username               = var.ssh_username
  zones                        = var.zones
  proximity_placement_group_id = var.proximity_placement_group_id
  platform_fault_domain_count  = local.platform_fault_domain_count_unf

  admin_ssh_key {
    username   = var.ssh_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  custom_data = base64encode(
    <<-EOF
            #!/bin/bash

            sudo apt-get install -y jq
            echo "deb [arch="$(dpkg --print-architecture)" trusted=yes] https://signup.volumez.com/ai/ubuntu stable main" | sudo tee  /etc/apt/sources.list.d/vlzconnector.list
            sudo mkdir -p /opt/vlzconnector
            refreshtoken=${var.vlz_refresh_token} 
            idtoken=`curl https://ai.api.volumez.com/tenant/apiaccess/credentials/refresh -H "refreshtoken:$refreshtoken" | jq -r ".IdToken"`
            tenanttoken=`curl https://ai.api.volumez.com/tenant/token -H "authorization:$idtoken" -H 'content-type: application/json'  | jq -r ".AccessToken"`
            echo -n $tenanttoken | sudo tee /opt/vlzconnector/tenantToken
            sudo apt update
            sudo DEBIAN_FRONTEND=noninteractive apt install -q -y vlzconnector
        EOF
  )

  source_image_reference {
    publisher = var.media_image_publisher
    offer     = var.media_image_offer
    sku       = var.media_image_sku
    version   = var.media_image_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadOnly"
    diff_disk_settings {
      option    = "Local"
      placement = "ResourceDisk"
    }
  }

  network_interface {
    name                          = "vlz-nic"
    primary                       = true
    enable_accelerated_networking = true

    ip_configuration {
      name      = "vlz-internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss" {
  count                        = var.vmss_type == "flexible" ? 1 : 0
  name                         = var.vmss_name
  resource_group_name          = var.resource_group_name
  location                     = var.resource_group_location
  sku_name                      = var.media_node_type
  instances                    = var.media_node_count
  zones                        = var.zones
  proximity_placement_group_id = var.proximity_placement_group_id
  platform_fault_domain_count  = local.platform_fault_domain_count_flex

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

          sudo apt-get install -y jq
          echo "deb [arch="$(dpkg --print-architecture)" trusted=yes] https://signup.volumez.com/ai/ubuntu stable main" | sudo tee  /etc/apt/sources.list.d/vlzconnector.list
          sudo mkdir -p /opt/vlzconnector
          refreshtoken=${var.vlz_refresh_token} 
          idtoken=`curl https://ai.api.volumez.com/tenant/apiaccess/credentials/refresh -H "refreshtoken:$refreshtoken" | jq -r ".IdToken"`
          tenanttoken=`curl https://ai.api.volumez.com/tenant/token -H "authorization:$idtoken" -H 'content-type: application/json'  | jq -r ".AccessToken"`
          echo -n $tenanttoken | sudo tee /opt/vlzconnector/tenantToken
          sudo apt update
          sudo DEBIAN_FRONTEND=noninteractive apt install -q -y vlzconnector
      EOF
    )
  }

  source_image_reference {
    publisher = var.media_image_publisher
    offer     = var.media_image_offer
    sku       = var.media_image_sku
    version   = var.media_image_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadOnly"
    diff_disk_settings {
      option    = "Local"
      placement = "ResourceDisk"
    }
  }

  network_interface {
    name                          = "vlz-nic"
    primary                       = true
    enable_accelerated_networking = true

    ip_configuration {
      name      = "vlz-internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }
}
