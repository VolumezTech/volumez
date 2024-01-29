provider "azurerm" {
  features {}
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

locals {
  use_ppg                 = length(var.zones) <= 1 ? true : false
  app_proximity_group_id   = var.app_proximity_placement_group ? azurerm_proximity_placement_group.this[0].id : null
}

###############
### Network ###
###############

module "resource-group" {
  source                  = "../../../modules/resource-group"
  resource_prefix         = var.resource_prefix
  resource_group_location = var.resource_group_location
  address_space           = var.address_space
  address_prefixes        = var.address_prefixes
  random_string           = random_string.this.result
}

resource "azurerm_proximity_placement_group" "this" {
  count               = local.use_ppg && var.app_proximity_placement_group ? 1 : 0
  name                = "pg"
  location            = module.resource-group.rg_location
  resource_group_name = module.resource-group.rg_name

  tags = {
    environment = "Volumez"
  }

  depends_on = [
    module.resource-group
  ]
}

resource "azurerm_nat_gateway" "this" {
  location            = module.resource-group.rg_location
  resource_group_name = module.resource-group.rg_name
  name                = "natgateway"
  sku_name            = "Standard"
}

resource "azurerm_public_ip_prefix" "nat_prefix" {
  name                = "pipp-nat-gateway"
  resource_group_name = module.resource-group.rg_name
  location            = module.resource-group.rg_location
  ip_version          = "IPv4"
  prefix_length       = 28
  sku                 = "Standard"
  zones               = var.zones
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.nat_prefix.id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = module.resource-group.subnet_id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_prefix}-${random_string.this.result}-cluster"
  location            = module.resource-group.rg_location
  resource_group_name = module.resource-group.rg_name
  kubernetes_version  = var.k8s_version
  dns_prefix          = var.dns_prefix
  sku_tier            = "Standard"

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userAssignedNATGateway"
    nat_gateway_profile {
      idle_timeout_in_minutes = 4
    }
  }

  default_node_pool {
    name           = "agentpool"
    vm_size        = "Standard_D8s_v3"
    os_disk_type   = "Ephemeral"
    node_count     = 1
    vnet_subnet_id = module.resource-group.subnet_id

    node_labels = {
      "avoid-csi" = true
    }
  }

  identity {
    type = var.identity_type
  }

  tags = {
    Owner = "Volumez"
  }
  depends_on = [azurerm_subnet_nat_gateway_association.this, azurerm_nat_gateway_public_ip_prefix_association.nat_ips]
}

resource "azurerm_kubernetes_cluster_node_pool" "app" {
  count                        = var.app_node_count > 0 ? 1 : 0
  name                         = "app"
  node_count                   = var.app_node_count
  vm_size                      = var.app_node_type
  zones                        = var.zones
  enable_auto_scaling          = true
  mode                         = "User"
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id               = module.resource-group.subnet_id
  max_count                    = var.app_node_count
  min_count                    = var.app_node_count
  orchestrator_version         = var.k8s_version
  os_disk_size_gb              = "128"
  proximity_placement_group_id = local.use_ppg && var.app_proximity_placement_group  ? azurerm_proximity_placement_group.this[0].id : null
  priority                     = "Regular"
  node_labels = {
    "nodepool-type" = "app"
    "environment"   = "dev"
  }
  tags = {
    "nodepool-type" = "user"
    "environment"   = "dev"
  }
}

# module "bastion" {
#   source = "../../../modules/bastion"

#   location                   = module.resource-group.rg_location
#   rg-name                    = module.resource-group.rg_name
#   environment                = "dev"
#   tf_vnet1_name              = "vnet"
#   azbastion-subnet-address   = ["10.1.5.0/24"]
#   firewall_allocation_method = "Static"
#   firewall_sku               = "Standard"
#   azb_scl_units              = 2
# }
