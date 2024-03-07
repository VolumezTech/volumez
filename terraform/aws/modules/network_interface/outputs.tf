output "nodes_eni_ids" {
  value       = aws_network_interface.this.*.id
  description = "List of nodes eni ids"
}