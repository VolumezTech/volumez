output "instance_ids" {
  value = aws_instance.node[*].id
}

output "hostnames" {
  value = [for i in range(var.num_of_nodes) : "${var.hostname_prefix}-${i}"]
}

output "public_ips" {
  value = aws_instance.node[*].public_ip
}

output "private_ips" {
  value = aws_instance.node[*].private_ip
}

output "service_ips" {
  # Same formula the ENIs are created with — known at plan time
  value = [for i in range(var.num_of_nodes) : cidrhost(var.service_subnet_cidr, var.service_ip_start + i)]
}
