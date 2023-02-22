output "vm_names" {
    value       = azurerm_linux_virtual_machine.this.*.name
}

output "vm_public_ips" {
    value       = azurerm_linux_virtual_machine.this.*.public_ip_address
}

output "vm_private_ips" {
    value       = azurerm_linux_virtual_machine.this.*.private_ip_address
}