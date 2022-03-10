terraform {
    required_version = ">=0.14"
}

resource "aws_placement_group" "env_pg" {
    count    = var.num_of_zones
    
    name     = "Volumez-pg-${count.index}"
    strategy = var.placement_group_strategy
}