output "private_sn_ids" {
  value       = aws_subnet.private_sn.*.id
  description = "List of private subnets"
}

output "public_sn_id" {
  value       = aws_subnet.public_sn.id
  description = "id of public subnet"
}