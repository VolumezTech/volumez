###############
### Network ###
###############
variable "vlz_tenant_token" {
    description = "Tenant token to access Cognito and pull the connector"
    type        = string
}

variable "resource_prefix" {
  type    = string
  default = "netapp-unf"
}

variable "resource_group_location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type    = string
  description = "Target resource group name"
}

variable zones {
  type    = list
  default = ["1"]
}

variable "virtual_network_name" { 
  type = string
  description = "Target virtual network name" 
}

variable "nat_gateway_id" {
  type = string
  description = "Target nat gateway id (if not entered, will create new one)"
}

variable "proximity_placement_group_id" { 
  type = string
  description = "Target proximity placement group id. null - if no ppg needed" 
}

variable "address_space" {
  type    = list
  default = ["10.1.0.0/16"]
}

variable "address_prefixes" {
  type    = list
  default = ["10.1.3.0/24"]
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