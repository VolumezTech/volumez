output "pub_sn_ids" {
    value       = aws_subnet.public_sn.*.id
    description = "List of mgmg subnets"
}