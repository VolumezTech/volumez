terraform {
  required_version = ">=0.14"
}

resource "aws_network_interface" "this" {
  count = var.num_of_nodes

  subnet_id       = var.num_of_zones == 1 || length(var.private_sn_ids) == 1 ? var.private_sn_ids[0] : var.private_sn_ids[count.index % var.num_of_zones]
  security_groups = [var.env_sg_id]

  tags = {
    Name      = "Volumez-eni-pub-${count.index}"
    Terraform = "true"
  }
}