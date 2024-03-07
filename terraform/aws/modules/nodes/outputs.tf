output "node_id" {
  value       = aws_instance.this.*.id
  description = "List of sio ids"
}

output "node_public_dns" {
  value       = aws_instance.this.*.public_dns
  description = "List of sio public dns addrs"
}

output "node_private_dns" {
  value       = aws_instance.this.*.private_dns
  description = "List of hosts private dns addrs"
}
