



resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  partition_count = min(var.node_count, 7)
}

resource "aws_placement_group" "env_pg" {
  count           = var.num_of_zones
  name            = "Volumez-pg-${count.index}-${random_string.suffix.result}"
  strategy        = var.placement_group_strategy
  partition_count = var.placement_group_strategy == "partition" ? local.partition_count : null
}