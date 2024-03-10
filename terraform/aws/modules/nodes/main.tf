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
  placement_group      = var.num_of_zones == 1 || count.index >= length(var.placement_group_ids) ? var.placement_group_ids[0] : var.placement_group_ids[count.index % var.num_of_zones]
  network_interface {
    network_interface_id = var.pub_eni_list[count.index]
    device_index         = 0
  }

  tags = {
    Name      = "${var.app_node_name_prefix}-${count.index}-${var.resources_name_suffix}"
    Terraform = "true"
    Owner     = data.aws_caller_identity.current.user_id
  }
  user_data = base64encode(templatefile("../../../../../scripts/deploy_connector.sh", { tenant_token = var.tenant_token, signup_domain = var.signup_domain }))

}