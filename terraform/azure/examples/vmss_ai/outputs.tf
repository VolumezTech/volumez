output "vmss_name" {
  value = azurerm_orchestrated_virtual_machine_scale_set.app.name
}

output "media_private_ips" {
  value = [azurerm_linux_virtual_machine.media.*.private_ip_address]

}

output "bastion_public_ip" {
  value = module.bastion.*.azb-pubIP-ipadr
}

output "ssh_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}