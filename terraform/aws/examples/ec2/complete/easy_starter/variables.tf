###############
### Network ###
###############

variable "region" {
  description = "Enter the region you want to create the environment in (example: us-east-1):"
  type        = string
}

variable "resources_name_suffix" {
  default = "Volumez"
}

variable "subnet_cidr_list" {
  default = ["10.0.85.0/24", "10.0.86.0/24", "10.0.87.0/24", "10.0.88.0/24"]
}

variable "num_of_zones" {
  default = 2
}

variable "create_fault_domain" {
  type    = bool
  default = false
}

variable "placement_group_strategy" {
  default = "cluster"
}

variable "signup_domain" {
  description = "signup url to take vlzconnector from"
  type        = string
  default     = "signup.volumez.com"
}

### Optional VPC and Subnet IDs ###
variable "target_vpc_id" {
  description = "VPC ID to launch the instance in"
  type        = string
  default     = ""
}

variable "target_subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
  default     = ""
}


variable "target_security_group_id" {
  description = "Security Group ID to launch the instance in"
  type        = string
  default     = ""
}

variable "target_placement_group_id" {
  description = "Placement Group ID to launch the instance in"
  type        = string
  default     = ""
}

variable "avoid_pg" {
  description = "Avoid using Proximity Placement Group"
  type        = bool
  default     = false
}

variable "deploy_bastion" {
  type    = bool
  default = true
}



############
### Keys ###
############

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource; ; if not set - new one will be generated"
  type        = string
  default     = ""
}

variable "path_to_pem" {
  description = "pem key path to use for ssh into the instance; which can be managed using the `aws_key_pair` resource; if not set - new one will be generated"
  type        = string
  default     = ""
}

variable "tenant_token" {
  description = "Enter your Volumez Tenant Token (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info"
  type        = string
}

###################
### Media Nodes ###
###################

variable "media_node_count" {
  type    = number
  default = 8
}

variable "media_node_type" {
  type    = string
  default = "is4gen.2xlarge"
}

variable "media_node_iam_role" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}

variable "media_node_ami" {
  type    = string
  default = "default"
}

variable "media_node_ami_username" {
  description = "ssh username for media nodes for relevant ami id"
  type        = string
  default     = "default"
}

variable "media_node_name_prefix" {
  type    = string
  default = "media"
}

###################
### App Nodes ###
###################

variable "app_node_count" {
  description = "number of performance hosts"
  default     = 0
}

variable "app_node_type" {
  description = "EC2 type for application node"
  type        = string
  default     = "m5n.xlarge"
}

variable "app_node_iam_role" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}

variable "app_node_ami" {
  type    = string
  default = "default"
}

variable "app_node_ami_username" {
  description = "ssh username for application nodes for relevant ami id"
  type        = string
  default     = "default"
}

variable "app_node_name_prefix" {
  type    = string
  default = "app"
}

