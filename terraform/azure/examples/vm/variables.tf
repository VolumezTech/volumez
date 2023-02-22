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
  default = ["10.0.1.0/24"]
}

variable "ssh_username" {
  type    = string
  default = "adminuser"
}

variable "ssh_key_name" {
  type    = string
  default = "automation-kp"
}

#############
### media ###
#############

variable "num_of_media_vm" {
  type    = number
  default = 2
}

variable "media_vm_type" {
  type    = string
  default = "Standard_L8as_v3" #i4i.2xlarge
}

###########
### app ###
###########

variable "num_of_app_vm" {
  type    = number
  default = 0
}

variable "app_vm_type" {
  type    = string
  default = "Standard_D64_v5"
}
