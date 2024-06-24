

resource "aws_vpc" "env_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name      = "vpc-${var.resources_name_prefix}"
    Terraform = "true"
  }
}