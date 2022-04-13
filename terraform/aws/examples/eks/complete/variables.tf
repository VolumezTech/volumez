variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_owner" {
  type        = string
  description = "Please enter cluster owner name/tag"
}

variable "number_of_nodes" {
  type        = number
  description = "Please enter the number of nodes you desire"
}

variable "ec2_type" {
  type        = string
  description = "Please enter EC2 Instance Type. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
}
