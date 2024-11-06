/*
  This Terraform file defines the infrastructure for a bastion host in AWS.
  The bastion host is a secure gateway that allows SSH access to other instances in the VPC.
  It creates the following resources:
  - aws_security_group: Defines the ingress and egress rules for SSH access.
  - aws_security_group_rule: Allows inbound SSH traffic from the specified security group.
  - aws_network_interface: Creates a network interface for the bastion host.
  - aws_network_interface_sg_attachment: Attaches the security group to the network interface.
  - aws_instance: Creates the bastion host EC2 instance.
  - null_resource: Configures SSH access to the bastion host by copying the private key and updating permissions.

  Required Variables:
  - vpc_id: The ID of the VPC where the bastion host will be deployed.
  - pub_sn_id: The ID of the public subnet where the bastion host will be deployed.
  - sg_list: A list of security group IDs to attach to the bastion host.
  - bastion_ec2_type: The EC2 instance type for the bastion host.
  - ami_id_bastion: The ID of the AMI to use for the bastion host.
  - key_pair: The name of the key pair to use for SSH access to the bastion host.
  - iam_role: The IAM instance profile to associate with the bastion host.

  Outputs:
  - None
*/



// New sg for bastion with ssh 22 from all
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-${var.resources_name_prefix}-sg"
  vpc_id = var.vpc_id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "bastion-${var.resources_name_prefix}-sg"
    Terraform = "true"
  }
}

resource "aws_security_group_rule" "example" {
  // add rule to allow ssh from bastion sg to the first sg in the list
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = var.sg_list[0]

  depends_on = [
    aws_security_group.bastion_sg
  ]
}

resource "aws_network_interface" "pub-bastion" {
  subnet_id       = var.pub_sn_id[0]
  security_groups = [aws_security_group.bastion_sg.id]
}

data "aws_ami" "bastion_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "bastion" {
  instance_type        = var.bastion_ec2_type
  ami                  = data.aws_ami.bastion_ami.id
  key_name             = var.key_pair

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  network_interface {
    network_interface_id = aws_network_interface.pub-bastion.id
    device_index         = 0
  }


  tags = {
    Name      = "${var.resources_name_prefix}-bastion"
    Terraform = "true"
  }
}