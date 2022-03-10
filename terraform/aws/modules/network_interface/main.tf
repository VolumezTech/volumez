terraform {
    required_version = ">=0.14"
}

resource "aws_network_interface" "this" {
  count           = var.num_of_nodes

  subnet_id       = var.num_of_zones == 1 ? var.pub_sn_ids[0] : var.pub_sn_ids[count.index % var.num_of_zones]
  security_groups = [var.env_sg_id]
  private_ips     =  var.num_of_zones == 1 ? [ "${var.pub_ip_cidr_tmpl[0]}.${count.index + var.start_ip}" ] : [ "${var.pub_ip_cidr_tmpl[count.index % var.num_of_zones]}.${count.index + var.start_ip}" ]

  tags = {
    Name      = "Volumez-eni-pub-${count.index}"
    Terraform = "true"
  }
}