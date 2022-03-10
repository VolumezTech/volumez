terraform {
    required_version = ">=0.14"
}

resource "aws_default_security_group" "this" {
  vpc_id       = var.vpc_id
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    protocol    = -1  
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.ingress_cidr_block 
  }  
  
  #allow egress of all ports
  egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = var.ingress_cidr_block 
  }

  tags = {
    Name = "Volumez-sg"
    Terraform = "true"
  }
}