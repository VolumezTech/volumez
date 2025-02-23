variable "vmss_type" {
    description = "Type of virtual machine scale set"
    type        = string
    default     = "linux" 
}

variable "resource_group_name" {
    description = "The name of the resource group in which to create the virtual machine scale set"
    type        = string
}

variable "resource_group_location" {
    type    = string
    default = "eastus" 
}

variable "vmss_name" {
    type = string
}

variable "media_node_type" {
    type = string
  
}

variable "media_node_count" {
    type = number
  
}

variable "ssh_username" {
    type = string
    default = "adminuser"
}

variable "zones" {
    type = list(string)
    default = [ "1" ]
}

variable "proximity_placement_group_id" {
    type = string
    default = null
  
}

variable "single_ppg" {
    type    = bool
    default = true
  
}

variable "create_fault_domain" {
    type    = bool
    default = true
  
}

variable "platform_fault_domain_count" {
    type    = number
    default = 5
  
}

variable "vlz_refresh_token" {
    type = string
  
}

variable "media_image_offer" {
    type = string
  
}

variable "media_image_publisher" {
    type = string
  
}   

variable "media_image_sku" {
    type = string
  
}       

variable "media_image_version" {
    type = string
  
}   

variable "subnet_id" {
    type = string
    default = null

}

variable "public_key" {
    type = string
    default = null
  
}

variable "apigw_endpoint" {
    type = string
    default = "https://api.volumez.com"
}

variable "vlzconnector_repo" {
    type = string
    default = "https://signup.volumez.com/connector/ubuntu"
}