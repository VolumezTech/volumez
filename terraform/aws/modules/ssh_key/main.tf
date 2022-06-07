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

data "aws_secretsmanager_secret" "ssh_val" {
  arn = aws_secretsmanager_secret.secret_key.arn

  depends_on = [
    aws_secretsmanager_secret.secret_key
  ]
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.ssh_val.arn

  depends_on = [data.aws_secretsmanager_secret.ssh_val]
}

locals {
  db_creds = data.aws_secretsmanager_secret_version.creds.secret_string
}
