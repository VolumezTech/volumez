variable "region" {
  description = "Please enter the region. For example: us-east-1"
  type    = string
}

variable "cluster_owner" {
  type        = string
  description = "Please enter cluster owner name/tag"
}

variable "number_of_media_nodes" {
  type        = number
  description = "Please enter the number of nodes you desire"
}

variable "number_of_app_nodes" {
  type        = number
  description = "Please enter the number of application nodes you desire"
}

variable "ec2_type_media" {
  type        = string
  description = "Please enter EC2 Instance Type for media nodes. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
}


variable "ec2_type_app" {
  type        = string
  description = "Please enter EC2 Instance Type for application nodes. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
}