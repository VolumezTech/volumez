terraform {
  required_version = ">=0.14"
}

data "aws_ami" "rhel_85" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-8.5.0_HVM-*-x86_64-0-Hourly2-GP2"]
  }
}

resource "aws_instance" "this" {
  count                = var.num_of_nodes

  instance_type        = var.node_type
  ami                  = var.ami_id == "default" ? data.aws_ami.rhel_85.id : var.ami_id
  key_name             = var.key_name
  iam_instance_profile = var.iam_role
  placement_group      = var.num_of_zones == 1 ? var.placement_group_ids[0] : var.placement_group_ids[count.index % var.num_of_zones]

  network_interface {
    network_interface_id = var.pub_eni_list[count.index]
    device_index         = 0
  }

  tags = {
    Name        = "${var.app_node_name_prefix}-${count.index}-Volumez"
    Terraform   = "true"
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
    source      = "${path.module}/deploy_connector.sh"
    destination = "/tmp/deploy_connector.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/deploy_connector.sh",
      "sudo /tmp/deploy_connector.sh ${var.tenant_token}"
    ]
  }
 
  depends_on = [
    aws_instance.this
  ]
}