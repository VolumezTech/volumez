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

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_prefix}-${random_string.this.result}-cluster"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
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
    vnet_subnet_id = var.vnet_subnet_id

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
  vm_size                      = var.media_node_size
  zones                        = [1]
  enable_auto_scaling          = false
  enable_node_public_ip        = true
  mode                         = "User"
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id               = var.vnet_subnet_id
  orchestrator_version         = var.k8s_version
  os_disk_size_gb              = 30
  proximity_placement_group_id = var.media_proximity_placement_group_id
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
  vm_size                      = var.app_node_size
  zones                        = [1]
  enable_auto_scaling          = true
  enable_node_public_ip        = true
  mode                         = "User"
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id               = var.vnet_subnet_id
  max_count                    = var.app_node_count
  min_count                    = var.app_node_count
  orchestrator_version         = var.k8s_version
  os_disk_size_gb              = 30
  proximity_placement_group_id = var.app_proximity_placement_group_id
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

