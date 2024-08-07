variable "region" {
  type        = string
  description = "Please enter the region. For example: us-east-1"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.29"
}

variable "resource_prefix" {
  type        = string
  description = "Please enter the cluster owner name/tag"
  default     = "Volumez"
}

variable "media_node_count" {
  type        = number
  description = "Please enter the number of media nodes you desire"
  default     = 6
}

variable "media_node_type" {
  type        = string
  description = "Please enter EC2 Instance Type for media nodes. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
  default     = "i3en.3xlarge"
}

variable "media_node_ami_type" {
  type        = string
  description = "media node ami type - AL2_x86_64/AL2_ARM_64"
  default     = "AL2_x86_64"
  validation {
    condition     = contains(["AL2_x86_64", "AL2_ARM_64"], var.media_node_ami_type)
    error_message = "Valid values for var: media_node_ami_type are (AL2_x86_64, AL2_ARM_64)."
  }
}

variable "app_node_count" {
  type        = number
  description = "Please enter the number of app nodes you desire"
  default     = 0
}

variable "app_node_type" {
  type        = string
  description = "Please enter EC2 Instance Type for app nodes. For example: 'i3.large'. You can see a list of them here: https://aws.amazon.com/ec2/instance-types/ "
  default     = "m5n.xlarge"
}

variable "app_node_ami_type" {
  type        = string
  description = "app node ami type - AL2_x86_64/AL2_ARM_64"
  default     = "AL2_x86_64"
  validation {
    condition     = contains(["AL2_x86_64", "AL2_ARM_64"], var.app_node_ami_type)
    error_message = "Valid values for var: media_node_ami_type are (AL2_x86_64, AL2_ARM_64)."
  }
}
