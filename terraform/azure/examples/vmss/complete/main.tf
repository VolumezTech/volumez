provider "azurerm" {
  features {}
}
#######################
### Local Variables ###
#######################

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

locals {
  create_rg = var.target_resource_group_name == "" ? true : false
  use_ppg    = length(var.zones) <= 1 ? true : false
  resource_prefix = var.resource_prefix != "" ? "${var.resource_prefix}-${random_string.this.result}" : replace(var.target_resource_group_name, "-rg", "")
}

#####################
### Resorce Group ###
#####################

module "resource-group" {
  source = "../../../modules/resource-group"
  count                   = local.create_rg ? 1 : 0
  resource_prefix         = var.resource_prefix
  resource_group_location = var.resource_group_location
  address_prefixes        = var.address_prefixes
  random_string           = random_string.this.result
}

###############
### Network ###
###############


resource "azurerm_proximity_placement_group" "this" {
  count               = (local.use_ppg && local.create_rg) ? 1 : 0
  name                = "${local.resource_prefix}-ppg"
  resource_group_name = local.create_rg ? module.resource-group[0].rg_name : var.target_resource_group_name
  location            = local.create_rg ? module.resource-group[0].rg_location : var.target_resource_group_location

  tags = {
    environment = "Volumez"
  }

  depends_on = [
    module.resource-group
  ]
}

resource "azurerm_subnet" "this" {
  count                = (local.create_rg || var.target_subnet_id == null) ? 1 : 0
  name                 = "${local.resource_prefix}-sn"
  resource_group_name  = local.create_rg ? module.resource-group[0].rg_name : var.target_resource_group_name
  address_prefixes     = var.address_prefixes
  virtual_network_name = local.create_rg ? module.resource-group[0].vnet_name : var.target_virtual_network_name
}

### SECURITY GROUP ###

data "azurerm_network_security_group" "this" {
  count               = var.target_nsg_name != "" ? 1 : 0
  name                = var.target_nsg_name
  resource_group_name = local.create_rg ? module.resource-group[0].rg_name : var.target_resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = (var.target_subnet_id == null && var.target_nsg_name != "") ? 1 : 0
  subnet_id                 = azurerm_subnet.this[0].id 
  network_security_group_id = data.azurerm_network_security_group.this[0].id
}

### NAT GATAWY ###

resource "azurerm_nat_gateway" "this" {
  count               = (var.target_subnet_id == null && var.nat_gateway_id == "") ? 1 : 0
  location            = local.create_rg ? module.resource-group[0].rg_location : var.target_resource_group_location
  resource_group_name = local.create_rg ? module.resource-group[0].rg_name : var.target_resource_group_name
  name                = "${local.resource_prefix}-natgateway"
  sku_name            = "Standard"
}
 
resource "azurerm_public_ip_prefix" "nat_prefix" {
  count               = (var.target_subnet_id == null && var.nat_gateway_id == "") ? 1 : 0
  name                = "${local.resource_prefix}-pip-prefix"
  resource_group_name = local.create_rg ? module.resource-group[0].rg_name : var.target_resource_group_name
  location            = local.create_rg ? module.resource-group[0].rg_location : var.target_resource_group_location
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

###############
#### VMSS ####
###############

module "vmss" {
  source                        = "../../../modules/vmss"

  vmss_type                     = var.vmss_type
  vmss_name                     = "${local.resource_prefix}-vmss"
  resource_group_name           = local.create_rg ? module.resource-group[0].rg_name : var.target_resource_group_name
  resource_group_location       = local.create_rg ? module.resource-group[0].rg_location : var.target_resource_group_location
  media_node_type               = var.media_node_type
  media_node_count              = var.media_node_count
  ssh_username                  = var.ssh_username
  zones                         = var.zones
  proximity_placement_group_id  = local.create_rg && local.use_ppg ? azurerm_proximity_placement_group.this[0].id : (local.use_ppg ? var.target_proximity_placement_group_id : null)
  create_fault_domain           = var.create_fault_domain
  platform_fault_domain_count   = var.platform_fault_domain_count
  vlz_refresh_token             = var.vlz_refresh_token
  media_image_publisher         = var.media_image_publisher
  media_image_offer             = var.media_image_offer
  media_image_sku               = var.media_image_sku
  media_image_version           = var.media_image_version
  subnet_id                     = var.target_subnet_id != null ? var.target_subnet_id : azurerm_subnet.this[0].id

  depends_on = [ azurerm_nat_gateway_public_ip_prefix_association.nat_ips, azurerm_subnet_nat_gateway_association.this, azurerm_subnet.this, module.resource-group ]
}


##################
#### Bastion ####
#################

module "bastion" {
  source                   = "../../../modules/bastion"
  count                    = var.deploy_bastion ? 1 : 0
  location                 = local.create_rg ? module.resource-group[0].rg_location : var.target_resource_group_location
  rg-name                  = local.create_rg ? module.resource-group[0].rg_name : var.target_resource_group_name
  vnet_name                = local.create_rg ? module.resource-group[0].vnet_name : var.target_virtual_network_name
  azbastion-subnet-address = var.azbastion-subnet-address

  depends_on = [ azurerm_subnet.this, module.resource-group ]
}
