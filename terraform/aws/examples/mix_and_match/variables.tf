###############
### Network ###
###############

variable "region" {
}

variable "resources_name_suffix" {
     default = "Volumez"
}

variable "subnet_cidr_list" {
    default = ["10.0.85.0/24", "10.0.86.0/24", "10.0.87.0/24", "10.0.88.0/24"]
}

variable "num_of_zones" {
    description = "Number of Availability Zones"
    type        = number

    validation {
        condition     = var.num_of_zones <= 4
        error_message = "The number_of_zones must be smaller than length of subnet_cidr_list."
    }
}

variable "placement_group_strategy" {
    description = "Placement grpoup strategy. The placement strategy. Can be 'cluster', 'partition' or 'spread'"
    type        = string

    validation {
        condition     = contains(["cluster", "partition", "spread"], var.placement_group_strategy)
        error_message = "A placement_group_strategy must be 'cluster', 'partition' or 'spread'."
  } 
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
    description = "Number of media nodes to create"
    type        = number
}

variable "media_node_type" {
    description = "Media EC2 type"
    type        = string
}

variable "media_node_iam_role" {
    description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
    type        = string
    default     = null
}

variable "media_node_ami" {
    description = "Media node AMI ID"
    type        = string
    default     = "default"
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
}

variable "app_node_type" {
    description = "EC2 type for application node"
    type        = string
}

variable "app_node_iam_role" {
    description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
    type        = string
    default     = null
}

variable "app_node_ami" {
    description = "Application node AMI ID"
    type        = string
    default     = "default"
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