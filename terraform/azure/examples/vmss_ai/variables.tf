
#########################
#### Resource Group #####
#########################

variable "resource_group_prefix" {
  description = "The name of the resource group in which to create the VM"
  type        = string
  default     = "example-resource"

}

variable "resource_group_location" {
  description = "The location/region of the resource group in which to create the VM"
  type        = string
  default     = "East US"

}

##################
#### Bastion ####
#################

variable "deploy_bastion" {
  description = "Whether to deploy a bastion host for ssh access to the VM"
  type        = bool
  default     = true

}

variable "bastion_subnet_address_prefix" {
  description = "The address prefix for the subnet in which to deploy the bastion host"
  default     = ["10.0.8.0/26"]

}

######################
#### SSH Key #########
######################

variable "ssh_username" {
  description = "The username for ssh access to the VM"
  type        = string
  default     = "adminuser"

}

###########################
#### Deploy Connector #####
###########################

variable "tenant_token" {
  description = "Tenant token to access Cognito and pull the connector (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info"
  type        = string

}

variable "signup_domain" {
  description = "signup url to take vlzconnector from"
  type        = string
  default     = "signup.volumez.com"

}

##########################
#### Virtual Network #####
##########################

variable "vnet_address_space" {
  description = "The address space that is used the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]

}

variable "subnet_count" {
  description = "The number of subnets to create in the virtual network"
  type        = number
  default     = 8

}

###########################
#### Availability Set #####
###########################

variable "availability_set_fault_domain_count" {
  description = "The number of fault domains for the availability set"
  type        = number
  default     = 1

}

variable "availability_set_update_domain_count" {
  description = "The number of update domains for the availability set"
  type        = number
  default     = 1

}

####################
#### App VMSS #####
####################

variable "app_vmss_instances" {
  description = "The number of instances to create in the application VMSS"
  type        = number
  default     = 1

}

variable "app_vmss_instance_size" {
  description = "The SKU of the application VMSS"
  type        = string
  default     = "Standard_D64_v5"

}

variable "app_vmss_fault_domain_count" {
  description = "The number of fault domains for the application VMSS"
  type        = number
  default     = 1

}

variable "app_image_publisher" {
  description = "The publisher of the image to use for the application VMSS"
  type        = string
  default     = "Canonical"

}

variable "app_image_offer" {
  description = "The offer of the image to use for the application VMSS"
  type        = string
  default     = "0001-com-ubuntu-server-focal"

}

variable "app_image_sku" {
  description = "The SKU of the image to use for the application VMSS"
  type        = string
  default     = "20_04-lts"

}

variable "app_image_version" {
  description = "The version of the image to use for the application VMSS"
  type        = string
  default     = "latest"

}

####################
#### Media VMs #####
####################


variable "media_vm_count" {
  description = "The number of media VMs to create"
  type        = number
  default     = 8

}


variable "media_vm_size" {
  description = "The size of the media VM"
  type        = string
  default     = "Standard_L8s_v3"

}


variable "media_image_publisher" {
  description = "The publisher of the image to use for the media VM"
  type        = string
  default     = "Canonical"

}

variable "media_image_offer" {
  description = "The offer of the image to use for the media VM"
  type        = string
  default     = "0001-com-ubuntu-server-focal"

}

variable "media_image_sku" {
  description = "The SKU of the image to use for the media VM"
  type        = string
  default     = "20_04-lts"

}

variable "media_image_version" {
  description = "The version of the image to use for the media VM"
  type        = string
  default     = "latest"

}





