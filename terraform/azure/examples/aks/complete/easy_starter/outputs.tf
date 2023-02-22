###############
### Outputs ###
###############

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value = module.resource-group.rg_name
}