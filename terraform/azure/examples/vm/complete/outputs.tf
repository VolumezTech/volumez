###################
##### Outputs #####
###################

output "host-ids" {
    value = module.media-vm.vm_names
}

output "host-private-dns" {
    value = module.media-vm.vm_private_ips
}

output "apphost-ids" {
    value = module.app-vm.vm_names
}

output "apphost-private-dns" {
    value = module.app-vm.vm_private_ips
}

output "bastion-id" {
    value = module.bastion.*.azb-host-name 
}

output "bastion-public-ip" {
    value = module.bastion.*.azb-pubIP-ipadr  
}

output "tls_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}