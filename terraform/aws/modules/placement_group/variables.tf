variable "vpc_id" {
  description = "vpc id"
}

variable "num_of_zones" {
  description = "Number of AZ's"
  default     = 1
}

variable "node_count" {
  description = "Number of nodes"
  default     = 1
}

variable "placement_group_strategy" {
  description = "The placement strategy. Can be 'cluster', 'partition' or 'spread'"
  type        = string
  default     = "cluster"
}