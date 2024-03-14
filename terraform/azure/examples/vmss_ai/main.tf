# Define the Azure provider
provider "azurerm" {
  features {}
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}
######################
#### SSH Key #########
######################
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

######################
#### Local Vars  #####
######################
locals {
  resource_prefix = "${var.resource_group_prefix}-${random_string.this.result}"
}

#########################
#### Resource Group #####
#########################
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_prefix}-rg"
  location = var.resource_group_location
}

##########################
#### Virtual Network #####
##########################
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.resource_prefix}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

######################
#### Subnets #########
######################
resource "azurerm_subnet" "sn" {
  count                = var.subnet_count
  name                 = "${local.resource_prefix}-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index}.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

######################
#### NAT Gateway #####
######################
resource "azurerm_nat_gateway" "nat" {
  count               = 1
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${local.resource_prefix}-natgateway"
  sku_name            = "Standard"

  depends_on = [azurerm_resource_group.rg]
}

####################
#### Public IP #####
####################
resource "azurerm_public_ip_prefix" "nat_prefix" {
  count               = 1
  name                = "${local.resource_prefix}-pip-prefix"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_version          = "IPv4"
  prefix_length       = 28
  sku                 = "Standard"
  zones               = ["1"]

  depends_on = [azurerm_resource_group.rg]
}


resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  count               = 1
  nat_gateway_id      = azurerm_nat_gateway.nat[0].id
  public_ip_prefix_id = azurerm_public_ip_prefix.nat_prefix[0].id

  depends_on = [azurerm_nat_gateway.nat, azurerm_public_ip_prefix.nat_prefix]
}


resource "azurerm_subnet_nat_gateway_association" "this" {
  count          = 8
  subnet_id      = azurerm_subnet.sn[count.index].id
  nat_gateway_id = azurerm_nat_gateway.nat[0].id

  depends_on = [azurerm_nat_gateway.nat, azurerm_subnet.sn]
}

####################
#### App VMSS #####
####################
resource "azurerm_orchestrated_virtual_machine_scale_set" "app" {
  name                        = "${local.resource_prefix}-app-vmss-${random_string.this.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  instances                   = var.app_vmss_instances
  sku_name                    = var.app_vmss_instance_size
  platform_fault_domain_count = var.app_vmss_fault_domain_count

  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = var.ssh_username

      admin_ssh_key {
        username   = var.ssh_username
        public_key = tls_private_key.ssh_key.public_key_openssh
      }
    }
  }

  source_image_reference {
    publisher = var.app_image_publisher
    offer     = var.app_image_offer
    sku       = var.app_image_sku
    version   = var.app_image_version
  }

  network_interface {
    name                          = "${local.resource_prefix}-app-nic-0"
    primary                       = true
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.resource_prefix}-app-internal"
      primary   = true
      subnet_id = azurerm_subnet.sn[0].id
    }
  }

  network_interface {
    name                          = "${local.resource_prefix}-app-nic-1"
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.resource_prefix}-app-internal-1"
      primary   = true
      subnet_id = azurerm_subnet.sn[1].id
    }
  }

  network_interface {
    name                          = "${local.resource_prefix}-app-nic-2"
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.resource_prefix}-app-internal-2"
      subnet_id = azurerm_subnet.sn[2].id
    }
  }

  network_interface {
    name                          = "${local.resource_prefix}-app-nic-3"
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.resource_prefix}-app-internal-3"
      subnet_id = azurerm_subnet.sn[3].id
    }
  }

  network_interface {
    name                          = "${local.resource_prefix}-app-nic-4"
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.resource_prefix}-app-internal-4"
      subnet_id = azurerm_subnet.sn[4].id
    }
  }

  network_interface {
    name                          = "${local.resource_prefix}-app-nic-5"
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.resource_prefix}-app-internal-5"
      subnet_id = azurerm_subnet.sn[5].id
    }
  }

  network_interface {
    name                          = "${local.resource_prefix}-app-nic-6"
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.resource_prefix}-app-internal-6"
      subnet_id = azurerm_subnet.sn[6].id
    }
  }

  network_interface {
    name                          = "${local.resource_prefix}-app-nic-7"
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.resource_prefix}-app-internal-7"
      subnet_id = azurerm_subnet.sn[7].id
    }
  }

  user_data_base64 = base64encode(templatefile("../../../scripts/deploy_connector.sh", { tenant_token = var.tenant_token, signup_domain = var.signup_domain }))

  depends_on = [azurerm_resource_group.rg, azurerm_virtual_network.vnet, azurerm_subnet.sn]
}
###########################
#### Availability Set #####
###########################
resource "azurerm_availability_set" "as" {
  name                         = "${local.resource_prefix}-availability-set"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = var.availability_set_fault_domain_count
  platform_update_domain_count = var.availability_set_update_domain_count

  depends_on = [azurerm_resource_group.rg]
}

###########################
#### Netork Interface #####
###########################
resource "azurerm_network_interface" "nic" {
  count               = var.media_vm_count
  name                = "${local.resource_prefix}-media-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.resource_prefix}-media-internal"
    subnet_id                     = azurerm_subnet.sn[count.index % var.subnet_count].id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [azurerm_resource_group.rg, azurerm_subnet.sn]
}

####################
#### Media VMs #####
####################
resource "azurerm_linux_virtual_machine" "media" {
  count               = var.media_vm_count
  name                = "${local.resource_prefix}-media-vm-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.media_vm_size
  admin_username      = var.ssh_username
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]
  availability_set_id          = azurerm_availability_set.as.id
  proximity_placement_group_id = null

  admin_ssh_key {
    username   = var.ssh_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.media_image_publisher
    offer     = var.media_image_offer
    sku       = var.media_image_sku
    version   = var.media_image_version
  }

  custom_data = base64encode(templatefile("../../../scripts/deploy_connector.sh", { tenant_token = var.tenant_token, signup_domain = var.signup_domain }))

  depends_on = [azurerm_resource_group.rg, azurerm_network_interface.nic]
}

##################
#### Bastion ####
#################

module "bastion" {
  source                   = "../../modules/bastion"
  count                    = var.deploy_bastion ? 1 : 0
  location                 = azurerm_resource_group.rg.location
  rg-name                  = azurerm_resource_group.rg.name
  vnet_name                = azurerm_virtual_network.vnet.name
  azbastion-subnet-address = var.bastion_subnet_address_prefix

  depends_on = [azurerm_resource_group.rg, azurerm_linux_virtual_machine.media]
}