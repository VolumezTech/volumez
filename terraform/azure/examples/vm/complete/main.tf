provider "azurerm" {
  features {}
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

###############
### SSH ###
###############
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "ssh_public" {
  name                = "${var.resource_prefix}-${random_string.this.result}-ssh"
  location            = module.resource-group.rg_location
  resource_group_name = module.resource-group.rg_name
  public_key          = tls_private_key.ssh_key.public_key_openssh

  depends_on = [
    module.resource-group
  ]
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
  source = "../../../modules/vm"

  num_of_vm               = var.num_of_media_node
  vm_type                 = "${var.resource_prefix}-${random_string.this.result}-media"
  vm_size                 = var.media_node_type
  resource_group_location = module.resource-group.rg_location
  resource_group_name     = module.resource-group.rg_name
  image_publisher         = var.media_image_publisher
  image_offer             = var.media_image_offer
  image_sku               = var.media_image_sku
  image_version           = var.media_image_version
  subnet_id               = module.resource-group.subnet_id
  zones                   = var.zones
  proximity_pg_group_list = azurerm_proximity_placement_group.this.*.id
  ssh_username            = var.ssh_username
  public_key              = azurerm_ssh_public_key.ssh_public.public_key
  private_key             = tls_private_key.ssh_key.private_key_pem
  resource_name_prefix    = var.resource_prefix
  tenant_token            = var.tenant_token
  signup_domain           = var.signup_domain

  depends_on = [
    azurerm_proximity_placement_group.this,
    azurerm_ssh_public_key.ssh_public,
    module.resource-group
  ]
}
module "app-vm" {
  source = "../../../modules/vm"

  num_of_vm               = var.num_of_app_node
  vm_type                 = "${var.resource_prefix}-${random_string.this.result}-app"
  vm_size                 = var.app_node_type
  resource_group_location = module.resource-group.rg_location
  resource_group_name     = module.resource-group.rg_name
  image_publisher         = var.app_image_publisher
  image_offer             = var.app_image_offer
  image_sku               = var.app_image_sku
  image_version           = var.app_image_version
  subnet_id               = module.resource-group.subnet_id
  zones                   = var.zones
  proximity_pg_group_list = azurerm_proximity_placement_group.this.*.id
  ssh_username            = var.ssh_username
  public_key              = azurerm_ssh_public_key.ssh_public.public_key
  private_key             = tls_private_key.ssh_key.private_key_pem
  resource_name_prefix    = var.resource_prefix
  tenant_token            = var.tenant_token
  signup_domain           = var.signup_domain

  depends_on = [
    azurerm_proximity_placement_group.this,
    azurerm_ssh_public_key.ssh_public,
    module.resource-group
  ]
}

