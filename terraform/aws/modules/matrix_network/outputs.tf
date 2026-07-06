output "mgmt_vpc_id" {
  value = aws_vpc.mgmt.id
}

output "service_vpc_id" {
  value = aws_vpc.service.id
}

output "mgmt_subnet_id" {
  value = aws_subnet.mgmt.id
}

output "service_subnet_id" {
  value = aws_subnet.service.id
}

output "mgmt_sg_id" {
  value = aws_security_group.mgmt.id
}

output "service_sg_id" {
  value = aws_security_group.service.id
}
