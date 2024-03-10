terraform {
  required_version = ">=0.14"
}

resource "aws_default_security_group" "node_sg" {
  vpc_id = var.vpc_id

  #allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.ingress_cidr_block
  }

  tags = {
    Name      = "node-${var.resources_name_suffix}-sg"
    Terraform = "true"
  }
}