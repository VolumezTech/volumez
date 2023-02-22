provider "azurerm" {
  features {}
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
  source = "../../../../modules/resource-group"

  resource_prefix         = var.resource_prefix
  resource_group_location = var.resource_group_location
  address_space           = ["10.1.0.0/16"]
  address_prefixes        = ["10.1.0.0/24"]
  random_string           = random_string.this.result
}

resource "azurerm_proximity_placement_group" "this" {
  name                = "pg"
  location            = module.resource-group.rg_location
  resource_group_name = module.resource-group.rg_name

  tags = {
    environment = "Development"
  }

  depends_on = [
    module.resource-group
  ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_prefix}-${random_string.this.result}-cluster"
  location            = module.resource-group.rg_location
  resource_group_name = module.resource-group.rg_name
  kubernetes_version  = var.k8s_version
  dns_prefix          = var.dns_prefix
  default_node_pool {
    name                         = "media"
    zones                        = [1]
    node_count                   = var.media_node_count
    vm_size                      = var.media_node_size
    vnet_subnet_id               = module.resource-group.subnet_id
    enable_node_public_ip        = true
    proximity_placement_group_id = azurerm_proximity_placement_group.this.id
  }

  identity {
    type = var.identity_type
  }

  tags = {
    Environment = "Development"
  }
}
