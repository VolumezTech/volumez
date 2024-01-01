###############
### Network ###
###############
variable "resource_prefix" {
  description = "Resource group name prefix"
  type    = string
  default = "Volumez"
}

variable "resource_group_location" {
  description = "Resource group location (example: eastus)"
  type    = string
  default = "East US"
}

variable "zones" {
  description = "List of Availability Zones (example: [\"1\"] or [\"1\", \"2\"] or [\"1\", \"2\", \"3\"]"
  type    = list
  default = ["1", "2"]
}

variable "address_space" {
  type    = list
  default = ["10.1.0.0/16"]
}

variable "address_prefixes" {
  type    = list
  default = ["10.1.85.0/24"]
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


###############
##### SSH #####
###############

variable "ssh_username" {
  type    = string
  default = "adminuser"
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

variable "media_image_publisher" {
  default = "RedHat"
}

variable "media_image_offer" {
  default = "RHEL"
}

variable "media_image_sku" {
  default = "8_7"
}

variable "media_image_version" {
  default = "latest"
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

variable "app_image_publisher" {
  default = "RedHat"
}

variable "app_image_offer" {
  default = "RHEL"
}

variable "app_image_sku" {
  default = "8_7"
}

variable "app_image_version" {
  default = "latest"
}
