###############
### Network ###
###############
variable "resource_prefix" {
  type    = string
  default = "default-vm"
}

variable "resource_group_location" {
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
variable "ifautomation" {
    description = "boolean for profiling"
    default     = false
}
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

variable "dev_public_dns" {
     default = "dns"
}

variable "api_gw_ws_id" {
    description = "websocket id"
    default = "default_id_from_terraform"
}

#############
### media ###
#############

variable "num_of_media_node" {
  type    = number
  default = 1
}

variable "media_node_type" {
  type    = string
  default = "Standard_L8as_v3" #i4i.2xlarge
}

###########
### app ###
###########

variable "num_of_app_node" {
  type    = number
  default = 0
}

variable "app_node_type" {
  type    = string
  default = "Standard_D64_v5"
}
