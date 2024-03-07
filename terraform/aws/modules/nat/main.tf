resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.pub_sn_id

  tags = {
    Name = "nat-gateway-${var.resources_name_suffix}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_sn_ids)
  subnet_id      = var.private_sn_ids[count.index]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}