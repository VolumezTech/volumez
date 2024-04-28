###############
### Network ###
###############
variable "resource_group_location" {
  type        = string
  description = "Please enter the region. For example: East US"
}

variable "resource_prefix" {
  type        = string
  description = "Please enter the cluster name prefix"
}

variable "zones" {
  type         = list
  default      = ["1"]
}

variable "address_space" {
  type         = list
  default      = ["10.40.0.0/16"]
}

variable "address_prefixes" {
  type         = list
  default      = ["10.40.0.0/24"] 
}

variable "deploy_bastion" {
  type        = bool
  default     = false
  
}

###########
### k8s ###
###########

variable "k8s_version" {
  type        = string
  description = "Please enter the kubernetes version. For example: 1.24"
  default     = "1.29"
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
}

variable "dns_prefix" {
  type        = string
  default     = "aks"
}

#################
### App Nodes ###
##################

variable "app_node_type" {
  type        = string
  description = "Please enter node size for media nodes. For example: 'Standard_D64_v5'."
}

variable "app_node_count" {
  type        = number
  description = "Please enter the number of application nodes you desire"
}

#################
### Media Nodes ###
##################

variable "media_node_type" {
  type        = string
  description = "Please enter node size for media nodes. For example: 'Standard_D64_v5'."
}

variable "media_node_count" {
  type        = number
  description = "Please enter the number of media nodes you desire"
}
