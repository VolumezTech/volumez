variable "region" {
  type        = string
  description = "Please enter the region. For example: us-east-1"
  default     = "us-east-1"
}

variable "cluster_owner" {
  type        = string
  description = "Please enter the cluster owner name/tag"
  default     = "Volumez"
}

variable "media_node_count" {
  type        = number
  description = "Please enter the number of nodes you desire"
  default     = 8
}

variable "app_node_count" {
  type        = number
  description = "Please enter the number of application nodes you desire"
  default     = 1
}

variable "media_node_type" {
  type        = string
  description = "Please enter EC2 Instance Type for media nodes. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
  default     = "i3en.3xlarge"
}

variable "app_node_type" {
  type        = string
  description = "Please ente EC2 Instance Type for application nodes. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
  default     = "m5n.xlarge"
}