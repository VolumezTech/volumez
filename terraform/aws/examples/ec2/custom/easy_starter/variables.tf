###############
### Network ###
###############

variable "region" {
    description = "Enter the region you want to create the environment in (example: us-east-1):"
    type        = string   
}

variable "vpc_id" {
    description = "Enter the vpc id you want to create the environment in:"
    type        = string
}

variable "subnet_id_list" {
    description = "Enter the subnets id list you want to create the media nodes in:"
    type        = list
}

variable "security_group_id" {
    description = "Enter the security group id:"
    type        = string
}

variable "resources_name_suffix" {
     default = "Volumez"
}

variable "placement_group_strategy" {
    default = "cluster"
}

variable "signup_domain" {
    description = "signup url to take vlzconnector from"  
    type = string
    default = "signup.volumez.com"
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
    default = "i3en.3xlarge"
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