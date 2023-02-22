###############
### Network ###
###############

variable "resource_group_location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type    = string
  default = "East US"
}

variable "subnet_id" {
  type = string
}

variable "resource_name_prefix" {
  type    = string
  default = "vm"
}

variable "zones" {
  default = ["1"]
}

variable "proximity_pg_group_list" {
  type = list(any)
}

### SSH ###
variable "ssh_username" {
  type    = string
  default = "adminuser"
}

variable "public_key" {
  type = string
}

#############
### VM ###
#############

variable "num_of_vm" {
  type    = number
  default = 1
}

variable "vm_type" {
  type    = string
  default = "media"
}

variable "vm_size" {
  type    = string
  default = "Standard_L8as_v3" # == i4i.2xlarge
}
