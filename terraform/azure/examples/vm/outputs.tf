###################
##### Outputs #####
###################

output "host-ids" {
    value = module.media-vm.vm_names
}

output "host-private-dns" {
    value = module.media-vm.vm_private_ips
}

output "host-public-dns" {
    value = module.media-vm.vm_public_ips
}

output "apphost-ids" {
    value = module.app-vm.vm_names
}

output "apphost-private-dns" {
    value = module.app-vm.vm_private_ips
}

output "apphost-public-dns" {
    value = module.app-vm.vm_public_ips
}