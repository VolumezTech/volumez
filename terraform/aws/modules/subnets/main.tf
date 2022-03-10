terraform {
    required_version = ">=0.14"
}

locals {
  availability_zone_list = ["${var.region}a", "${var.region}b", "${var.region}c", "${var.region}d"]
}

resource "aws_subnet" "public_sn" {
  count                    = var.num_of_zones

  vpc_id                   = var.vpc_id
  cidr_block               = var.subnet_cidr_list[count.index]
  availability_zone        = local.availability_zone_list[count.index]
  map_public_ip_on_launch  = var.map_public_ip_on_launch

  tags = {
     Name      = "Volumez-pub-sn"
     Terraform = "true"
  }
}