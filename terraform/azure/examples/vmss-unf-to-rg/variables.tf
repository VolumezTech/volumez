###############
### Network ###
###############
variable "vlz_refresh_token" {
    description = "Refresh token to access Cognito and pull the connector"
    type        = string
}

variable "resource_prefix" {
  type    = string
  default = "netapp-unf"
}

variable "target_resource_group_location" {
  type    = string
  default = "East US"
}

variable "target_resource_group_name" {
  type    = string
  description = "Target resource group name"
}

variable zones {
  type    = list
  default = ["1"]
}

variable "target_virtual_network_name" { 
  type = string
  description = "Target virtual network name" 
}

variable "target_subnet_id" {
  type = string
  description = "Target subnet id (if not entered, will create new one)"
  
}

variable "target_nsg_name" {
  type = string
  description = "Target nsg name"
  default = ""
}

variable "nat_gateway_id" {
  type = string
  description = "Target nat gateway id (if not entered, will create new one)"
  default = ""
}

variable "target_proximity_placement_group_id" { 
  type = string
  description = "Target proximity placement group id. null - if no ppg needed" 
}

variable "address_prefixes" {
  type    = list
  default = ["10.40.1.0/26"]
}

variable "platform_fault_domain_count" {
  type    = number
  default = 5
}

###############
##### SSH #####
###############
variable "ssh_rg_name" { 
  type = string
  default = "static"
}

variable "ssh_username" {
  type    = string
  default = "adminuser"
}


#############
### media ###
#############

variable "media_node_count" {
  type    = number
  default = 12
}

variable "media_node_type" {
  type    = string
  default = "Standard_L8s_v3"
}
variable "nodes_OS" {
  description = "nodes OS"
  default     = "rhel"
}

variable "media_image_publisher" {
    description = "media source image publisher"
    default = "Canonical"
}
variable "media_image_offer" {
    description = "media source image offer"
    default = "0001-com-ubuntu-server-jammy"
}
variable "media_image_sku" {
    description = "media source image sku"
    default = "22_04-lts"
}
variable "media_image_version" {
    description = "media source image version"
    default = "latest"
}
