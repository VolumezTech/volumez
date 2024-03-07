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

# ## Create the sensitive file for Private Key
# resource "local_sensitive_file" "ec2-bastion-host-private-key" {
#   depends_on      = [tls_private_key.key]
#   content         = tls_private_key.key.private_key_pem
#   filename        = "private_key.pem"
#   file_permission = "0400"
# }
