output "instance_ids" {
  value = aws_instance.node[*].id
}

output "hostnames" {
  value = [for i in range(var.num_of_nodes) : "${var.hostname_prefix}-${i}"]
}

output "public_ips" {
  # With Elastic IPs the EIP is the stable public address; the instance's
  # own public_ip attribute reflects the pre-association auto-assigned one.
  value = var.use_elastic_ip && var.assign_public_ip ? aws_eip.mgmt[*].public_ip : aws_instance.node[*].public_ip
}

output "private_ips" {
  value = aws_instance.node[*].private_ip
}

output "service_ips" {
  # Same formula the ENIs are created with — known at plan time
  value = [for i in range(var.num_of_nodes) : cidrhost(var.service_subnet_cidr, var.service_ip_start + i)]
}
