###############
### Network ###
###############

variable "region" {
     default = "us-east-1"
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

variable "placement_group_strategy" {
    default = "cluster"
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
    description = "Enter your Volumez tenant token (can be reached from Volumez->Add Storage->EC2->Next->(echo -n <tenant token>) )"
    type        = string
}

###################
### Media Nodes ###
###################

variable "media_node_count" {
     type    = number
     default = 4
}

variable "media_node_type" {
    type    = string
    default = "i3.large"
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