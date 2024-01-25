provider "azurerm" {
  features {}
}
locals {
  use_ppg    = length(var.zones) <= 1 ? true : false
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

resource "azurerm_subnet" "this" {
  count                = var.target_subnet_id == null ? 1 : 0
  name                 = "${var.resource_prefix}-${random_string.this.result}-sn"
  resource_group_name  = var.target_resource_group_name
  address_prefixes     = var.address_prefixes
  virtual_network_name = var.target_virtual_network_name
}

### SECURITY GROUP ###

data "azurerm_network_security_group" "this" {
  count               = var.target_nsg_name != "" ? 1 : 0
  name                = var.target_nsg_name
  resource_group_name = var.target_resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = (var.target_subnet_id == null && var.target_nsg_name != "") ? 1 : 0
  subnet_id                 = azurerm_subnet.this[0].id 
  network_security_group_id = data.azurerm_network_security_group.this[0].id
}

### NAT GATAWY ###

resource "azurerm_nat_gateway" "this" {
  count               = (var.target_subnet_id == null && var.nat_gateway_id == "") ? 1 : 0
  location            = var.target_resource_group_location
  resource_group_name = var.target_resource_group_name
  name                = "${var.resource_prefix}-${random_string.this.result}-natgateway"
  sku_name            = "Standard"
}
 
resource "azurerm_public_ip_prefix" "nat_prefix" {
  count               = (var.target_subnet_id == null && var.nat_gateway_id == "") ? 1 : 0
  name                = "${var.resource_prefix}-${random_string.this.result}-pip-prefix"
  resource_group_name = var.target_resource_group_name
  location            = var.target_resource_group_location
  ip_version          = "IPv4"
  prefix_length       = 28
  sku                 = "Standard"
  zones               = ["1"]
}
 
resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  count               = (var.target_subnet_id == null && var.nat_gateway_id == "") ? 1 : 0
  nat_gateway_id      = azurerm_nat_gateway.this[0].id
  public_ip_prefix_id = azurerm_public_ip_prefix.nat_prefix[0].id

  depends_on = [ azurerm_nat_gateway.this, azurerm_public_ip_prefix.nat_prefix ]
}
 
resource "azurerm_subnet_nat_gateway_association" "this" {
  count          = var.target_subnet_id == null ? 1 : 0
  subnet_id      = azurerm_subnet.this[0].id 
  nat_gateway_id = var.nat_gateway_id != "" ? var.nat_gateway_id : azurerm_nat_gateway.this[0].id

  depends_on = [ azurerm_subnet.this, azurerm_nat_gateway.this ]
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                         = "${var.resource_prefix}-${random_string.this.result}-vmss"
  resource_group_name          = var.target_resource_group_name
  location                     = var.target_resource_group_location
  sku                          = var.media_node_type
  instances                    = var.media_node_count
  admin_username               = var.ssh_username
  zones                        = var.zones
  proximity_placement_group_id = local.use_ppg ? var.target_proximity_placement_group_id : null
  single_placement_group       = var.single_ppg
  platform_fault_domain_count  = var.platform_fault_domain_count

  admin_ssh_key {
    username   = var.ssh_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  custom_data = base64encode(
    <<-EOF
            #!/bin/bash

            sudo apt-get install -y jq
            echo "deb [arch="$(dpkg --print-architecture)" trusted=yes] https://signup.volumez.com/connector/ubuntu stable main" | sudo tee  /etc/apt/sources.list.d/vlzconnector.list
            sudo mkdir -p /opt/vlzconnector
            refreshtoken=${var.vlz_refresh_token} 
            idtoken=`curl https://api.volumez.com/tenant/apiaccess/credentials/refresh -H "refreshtoken:$refreshtoken" | jq -r ".IdToken"`
            tenanttoken=`curl https://api.volumez.com/tenant/token -H "authorization:$idtoken" -H 'content-type: application/json'  | jq -r ".AccessToken"`
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
      subnet_id = var.target_subnet_id == null ? azurerm_subnet.this[0].id : var.target_subnet_id
    }
  }
}
