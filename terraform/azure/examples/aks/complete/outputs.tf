###############
### Outputs ###
###############

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value = module.resource-group.rg_name
}

output "virtual_network_name" {
  value = module.resource-group.vnet_name
}


output "subnet_id" {
  value = module.resource-group.subnet_id
}

output "proximity_placement_group_id" {
  value = azurerm_proximity_placement_group.this.id
}

