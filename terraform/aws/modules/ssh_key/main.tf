terraform {
    required_version = ">=0.14"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name_prefix = var.name_prefix
  public_key      = tls_private_key.key.public_key_openssh
}

resource "aws_secretsmanager_secret" "secret_key" {
  name_prefix = var.name_prefix
  description = var.description
  tags = merge(
    var.tags,
    { "Name" : "${var.name_prefix}-key" }
  )
}

resource "aws_secretsmanager_secret_version" "secret_key_value" {
  secret_id     = aws_secretsmanager_secret.secret_key.id
  secret_string = tls_private_key.key.private_key_pem

  depends_on = [
    aws_secretsmanager_secret.secret_key
  ]
}

locals {
  db_creds = aws_secretsmanager_secret_version.secret_key_value.secret_string
}
