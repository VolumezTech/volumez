terraform {
  required_version = ">=0.14"
}

data "aws_ec2_instance_type" "node-type-info" {
  instance_type = var.node_type
}

data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [data.aws_ec2_instance_type.node-type-info.supported_architectures[0]]
  }

  filter {
    name   = "name"
    values = ["RHEL-8.7.0_*"]
  }

  depends_on = [
    data.aws_ec2_instance_type.node-type-info
  ]
}

data "aws_caller_identity" "current" {}

resource "aws_instance" "this" {
  count                = var.num_of_nodes

  instance_type        = var.node_type
  ami                  = var.ami_id == "default" ? data.aws_ami.rhel.id : var.ami_id
  key_name             = var.key_name
  iam_instance_profile = var.iam_role
  placement_group      = var.num_of_zones == 1 ? var.placement_group_ids[0] : var.placement_group_ids[count.index % var.num_of_zones]

  network_interface {
    network_interface_id = var.pub_eni_list[count.index]
    device_index         = 0
  }

  tags = {
    Name        = "${var.app_node_name_prefix}-${count.index}-${var.resources_name_suffix}"
    Terraform   = "true"
    Owner       = data.aws_caller_identity.current.user_id
  }
}

resource "null_resource" "node_config" {
  count = var.num_of_nodes

  connection {
    type        = "ssh"
    user        = var.ami_username == "default" ? "ec2-user" : var.ami_username
    private_key = var.path_to_pem == "" ? var.key_value : file(var.path_to_pem)
    host        = aws_instance.this[count.index].public_dns
    agent       = false
  }

  provisioner "file" {
    source      = "../../../../../scripts/deploy_connector.sh"
    destination = "/tmp/deploy_connector.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${aws_instance.this[count.index].id}.ec2.internal"
      ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/deploy_connector.sh",
      "sudo /tmp/deploy_connector.sh ${var.tenant_token} ${var.signup_domain}"
    ]
  }
 
  depends_on = [
    aws_instance.this
  ]
}