output "key_name" {
  description = "Name of the keypair"
  value       = aws_key_pair.keypair.key_name
}

output "key_value" {
  value = aws_secretsmanager_secret_version.secret_key_value.secret_string
}
