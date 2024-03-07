output "key_name" {
  description = "Name of the keypair"
  value       = aws_key_pair.keypair.key_name
}

output "key_value" {
  value = tls_private_key.key.private_key_pem
}
