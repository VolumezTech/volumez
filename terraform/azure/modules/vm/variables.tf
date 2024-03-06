###############
### Network ###
###############

variable "resource_group_location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type    = string
  default = "Volumez"
}

variable "subnet_id" {
  type = string
}

variable "resource_name_prefix" {
  type    = string
  default = "Volumez"
}

variable "zones" {
  default = ["1", "2"]
}

variable "proximity_pg_group_list" {
  type = list(any)
}

variable "tenant_token" {
    description = "Tenant token to access Cognito and pull the connector"
    type        = string
}

variable "signup_domain" {
    description = "signup url to take vlzconnector from"  
    type = string
    default = "signup.volumez.com/ai"
}

###############
###   SSH   ###
###############
variable "ssh_username" {
  type    = string
  default = "adminuser"
}

variable "public_key" {
  type = string
}

variable "private_key" {
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

variable "image_publisher" {
  default = "RedHat"
}

variable "image_offer" {
  default = "RHEL"
}

variable "image_sku" {
  default = "8_7"
}

variable "image_version" {
  default = "latest"
}
