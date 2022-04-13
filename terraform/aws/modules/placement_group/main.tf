terraform {
    required_version = ">=0.14"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_placement_group" "env_pg" {
    count    = var.num_of_zones
    
    name     = "Volumez-pg-${count.index}-${random_string.suffix.result}"
    strategy = var.placement_group_strategy
}