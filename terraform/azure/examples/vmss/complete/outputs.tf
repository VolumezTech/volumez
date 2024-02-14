output "tls_private_key" {
  value     = module.vmss.tls_private_key
  sensitive = true
}
