locals {
  media_num_of_instances = length(var.subnet_cidr_block_list) > 1 ? var.media_num_of_instances / length(var.subnet_cidr_block_list) : var.media_num_of_instances
}