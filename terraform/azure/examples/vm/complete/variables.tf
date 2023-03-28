###############
### Network ###
###############
variable "resource_prefix" {
  description = "Resource group name prefix"
  type    = string
  default = "default-vm"
}

variable "resource_group_location" {
  description = "Resource group location"
  type    = string
  default = "East US"
}

variable "zones" {
  type    = list
  default = ["1"]
}

variable "address_space" {
  type    = list
  default = ["10.0.0.0/16"]
}

variable "address_prefixes" {
  type    = list
  default = ["10.0.85.0/24"]
}


###############
##### SSH #####
###############

variable "ssh_username" {
  type    = string
  default = "adminuser"
}

variable "ssh_key_name" {
  type    = string
  default = "automation-kp"
}

variable "path_to_pem" {
  type = string
  default = "~/.ssh/automation-kp.pem"
}

variable "tenant_token" {
    description = "Tenant token to access Cognito and pull the connector"
    type        = string
}

variable "signup_domain" {
    description = "signup url to take vlzconnector from"  
    type = string
    default = "signup.volumez.com"
}


#############
### media ###
#############

variable "num_of_media_node" {
  description = "Number of media nodes"
  type    = number
  default = 8
}

variable "media_node_type" {
  description = "Media node size"
  type    = string
  default = "Standard_L8as_v3" 
}

###########
### app ###
###########

variable "num_of_app_node" {
  description = "Number of app nodes"
  type    = number
  default = 0
}

variable "app_node_type" {
  description = "App node size"
  type    = string
  default = "Standard_D64_v5"
}
