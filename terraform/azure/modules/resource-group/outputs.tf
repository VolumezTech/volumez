output "rg_location" {
    value       = azurerm_resource_group.this.location
}

output "rg_name" {
    value       = azurerm_resource_group.this.name
}

output "subnet_id" {
    value       = azurerm_subnet.this.id
}

output "vnet_name" {
    value       = azurerm_virtual_network.this.name
}

output "nsg_id" {
    value       = azurerm_network_security_group.this.id
}