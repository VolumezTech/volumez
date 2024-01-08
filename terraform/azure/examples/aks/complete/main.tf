provider "azurerm" {
  features {}
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

locals {
  media_proximity_group_id = var.media_proximity_placement_group ? azurerm_proximity_placement_group.this.id : null
  app_proximity_group_id = var.app_proximity_placement_group ? azurerm_proximity_placement_group.this.id : null
}

###############
### Network ###
###############

module "resource-group" {
  source = "../../../modules/resource-group"
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
  sku_tier            = "Standard"

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2as_v5"
    node_count = 1
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
}

resource "azurerm_kubernetes_cluster_node_pool" "media" {
  count                        = var.media_node_count > 0 ? 1 : 0

  name                         = "media"
  node_count                   = var.media_node_count
  vm_size                      = var.media_node_type
  zones                        = var.zones
  enable_auto_scaling          = false
  enable_node_public_ip        = true
  mode                         = "User"
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id               = module.resource-group.subnet_id
  orchestrator_version         = var.k8s_version
  os_disk_size_gb              = 30
  proximity_placement_group_id = local.media_proximity_group_id
  priority                     = "Regular"

  
  node_labels = {
    "nodepool-type" = "media"
    "environment"   = "dev"
  }
  tags = {
    "nodepool-type" = "user"
    "environment"   = "dev"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "app" {
  count                        = var.app_node_count > 0 ? 1 : 0
  name                         = "app"
  node_count                   = var.app_node_count
  vm_size                      = var.app_node_type
  zones                        = var.zones
  enable_auto_scaling          = true
  enable_node_public_ip        = true
  mode                         = "User"
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id               = module.resource-group.subnet_id
  max_count                    = var.app_node_count
  min_count                    = var.app_node_count
  orchestrator_version         = var.k8s_version
  os_disk_size_gb              = 30
  proximity_placement_group_id = local.app_proximity_group_id
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

