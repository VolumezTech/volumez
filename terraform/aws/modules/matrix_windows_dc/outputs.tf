output "instance_id" {
  value = var.enabled ? aws_instance.dc[0].id : null
}

output "public_ip" {
  value = var.enabled ? (var.use_elastic_ip && var.assign_public_ip ? aws_eip.mgmt[0].public_ip : aws_instance.dc[0].public_ip) : null
}

output "private_ip" {
  value = var.enabled ? aws_instance.dc[0].private_ip : null
}
