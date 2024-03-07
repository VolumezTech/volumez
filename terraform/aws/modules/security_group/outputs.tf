output "sg_id" {
  description = "Security group id"
  value       = aws_default_security_group.node_sg.id
}