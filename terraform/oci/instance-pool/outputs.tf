output "tls_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
# output "all-availability-domains-in-your-tenancy" {
#   value = data.oci_identity_availability_domains.ads.availability_domains
# }
output "public-ip-media-instance-pool" {
  value = { for k, v in data.oci_core_instance.media_instance : k => [v.public_ip]... }
}
output "public-ip-app-instance-pool" {
  value = { for instance in data.oci_core_instance.app_instance : instance.id => [instance.public_ip]... }
}