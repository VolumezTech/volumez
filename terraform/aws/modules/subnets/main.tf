

locals {
  availability_zone_list = ["${var.region}a", "${var.region}b", "${var.region}c", "${var.region}d"]
}

resource "aws_subnet" "private_sn" {
  count                   = var.num_of_zones
  vpc_id                  = var.vpc_id
  cidr_block              = var.private_subnet_cidr_list[count.index]
  availability_zone       = local.availability_zone_list[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name      = "Private-SN-${var.resources_name_prefix}-${count.index + 1}"
    Terraform = "true"
  }
}

resource "aws_subnet" "public_sn" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.availability_zone_list[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-SN-${var.resources_name_prefix}"
  }
}