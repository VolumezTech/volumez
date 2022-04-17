variable "region" {
  type        = string
  description = "Please enter the region. For example: us-east-1"
}

variable "cluster_owner" {
  type        = string
  description = "Please enter the cluster owner name/tag"
}

variable "media_node_count" {
  type        = number
  description = "Please enter the number of nodes you desire"
}

variable "app_node_count" {
  type        = number
  description = "Please enter the number of application nodes you desire"
}

variable "media_node_type" {
  type        = string
  description = "Please enter EC2 Instance Type for media nodes. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
}

variable "app_node_type" {
  type        = string
  description = "Please ente EC2 Instance Type for application nodes. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
}