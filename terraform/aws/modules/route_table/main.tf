terraform {
    required_version = ">=0.14"
}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Volumez-igw"
    Terraform = "true"
  }
}

resource "aws_route" "public" {
  count                  = 1
  route_table_id         = var.default_rtb_id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }

  depends_on = [
    aws_internet_gateway.this
  ]
}