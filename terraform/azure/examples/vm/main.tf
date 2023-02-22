provider "azurerm" {
  features {}
}

data "azurerm_ssh_public_key" "this" {
  name                = var.ssh_key_name
  resource_group_name = "static"
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
  source = "../../../modules/azure/resource-group"

  resource_prefix         = var.resource_prefix
  resource_group_location = var.resource_group_location
  address_space           = var.address_space
  address_prefixes        = var.address_prefixes
  random_string           = random_string.this.result
}

# resource "azurerm_resource_group" "this" {
#   name     = "${var.resource_prefix}-${random_string.this.result}-rg"
#   location = var.resource_group_location
# }

resource "azurerm_proximity_placement_group" "this" {
  count = length(var.zones)

  name                = "pg-${count.index}"
  location            = module.resource-group.rg_location
  resource_group_name = module.resource-group.rg_name

  tags = {
    environment = "Development"
  }

  depends_on = [
    module.resource-group
  ]
}

#######
# VMs #
#######
module "media-vm" {
  source = "../../../modules/azure/vm"

  num_of_vm               = var.num_of_media_vm
  vm_type                 = "media"
  vm_size                 = var.media_vm_type
  resource_group_location = module.resource-group.rg_location
  resource_group_name     = module.resource-group.rg_name
  subnet_id               = module.resource-group.subnet_id
  zones                   = var.zones
  proximity_pg_group_list = azurerm_proximity_placement_group.this.*.id
  ssh_username            = var.ssh_username
  public_key              = data.azurerm_ssh_public_key.this.public_key
  resource_name_prefix    = var.resource_prefix
}

module "app-vm" {
  source = "../../../modules/azure/vm"

  num_of_vm               = var.num_of_app_vm
  vm_type                 = "app"
  vm_size                 = var.app_vm_type
  resource_group_location = module.resource-group.rg_location
  resource_group_name     = module.resource-group.rg_name
  subnet_id               = module.resource-group.subnet_id
  zones                   = var.zones
  proximity_pg_group_list = azurerm_proximity_placement_group.this.*.id
  ssh_username            = var.ssh_username
  public_key              = data.azurerm_ssh_public_key.this.public_key
  resource_name_prefix    = var.resource_prefix
}

###################
##### Outputs #####
###################

output "host-ids" {
    value = module.media-vm.vm_names
}

output "host-private-dns" {
    value = module.media-vm.vm_private_ips
}

output "host-public-dns" {
    value = module.media-vm.vm_public_ips
}

output "apphost-ids" {
    value = module.app-vm.vm_names
}

output "apphost-private-dns" {
    value = module.app-vm.vm_private_ips
}

output "apphost-public-dns" {
    value = module.app-vm.vm_public_ips
}