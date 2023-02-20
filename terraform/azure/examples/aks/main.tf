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
  kubernetes_version  = var.k8s_cluster_version
  dns_prefix          = var.dns_prefix
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = data.azurerm_ssh_public_key.this.public_key
    }
  }
  default_node_pool {
    name                         = "media"
    zones                        = var.zones_list
    node_count                   = var.num_of_media_node
    vm_size                      = var.media_node_type
    vnet_subnet_id               = module.resource-group.subnet_id
    enable_node_public_ip        = true
    proximity_placement_group_id = azurerm_proximity_placement_group.this.id
  }

  identity {
    type = var.identity_type
  }

  # network_profile {
  #   network_plugin    = "azure"
  #   network_policy    = "calico"
  #   load_balancer_sku = "standard"
  # }

  tags = {
    Environment = "Development"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                         = "app"
  node_count                   = var.num_of_app_node
  vm_size                      = var.app_node_type
  zones                        = var.zones_list
  enable_auto_scaling          = true
  enable_node_public_ip        = true
  mode                         = "User"
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id               = module.resource-group.subnet_id
  max_count                    = 1
  min_count                    = 1
  orchestrator_version         = var.k8s_cluster_version
  os_disk_size_gb              = 30
  proximity_placement_group_id = azurerm_proximity_placement_group.this.id
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

# resource "azurerm_kubernetes_cluster_node_pool" "app64" {
#   name                         = "appd"
#   node_count                   = var.num_of_app_node
#   vm_size                      = "Standard_D64_v5"
#   zones                        = var.zones_list
#   enable_auto_scaling          = true
#   enable_node_public_ip        = true
#   mode                         = "User"
#   kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
#   vnet_subnet_id               = module.resource-group.subnet_id
#   max_count                    = 1
#   min_count                    = 1
#   orchestrator_version         = var.k8s_cluster_version
#   os_disk_size_gb              = 30
#   proximity_placement_group_id = azurerm_proximity_placement_group.this.id
#   priority                     = "Regular"
#   node_labels = {
#     "nodepool-type" = "appd"
#     "environment"   = "dev"
#   }
#   tags = {
#     "nodepool-type" = "user"
#     "environment"   = "dev"
#   }
# }

###############
### Outputs ###
###############

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}