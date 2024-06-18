output "sg_id" {
  description = "Security group id"
  value       = aws_security_group.node_sg.id
}