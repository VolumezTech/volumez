

resource "aws_security_group" "node_sg" {
  name = "${var.resources_name_suffix}-sg"
  vpc_id = var.vpc_id

   ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 8009
    to_port     = 8009
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 3260
    to_port     = 3260
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

    ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 8765
    to_port     = 8765
    protocol    = "tcp"
  }
  
  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 47604
    to_port     = 47604
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 5149
    to_port     = 5149
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 8999
    to_port     = 8999
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = 6068
    to_port     = 6068
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingress_cidr_block  
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
  }
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