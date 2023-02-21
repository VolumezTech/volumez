###############
### Network ###
###############

variable "resource_group_location" {
  type        = string
  default     = "East US"
}

variable "resource_prefix" {
  type        = string
  default     = "Volumez-power-aks"
  description = "Please enter the cluster name prefix"
}

###########
### k8s ###
###########

variable "k8s_version" {
  type        = string
  default     = "1.24"
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
}

variable "dns_prefix" {
  type        = string
  default     = "aks"
}

###################
### Media Nodes ###
###################

variable "media_node_type" {
  type        = string
  default     = "Standard_L8s_v3"
}

variable "media_node_count" {
  type        = number
  default     = 8
}

#################
### App Nodes ###
##################

variable "app_node_type" {
  type        = string
  default     = "Standard_D64_v5"
}

variable "app_node_count" {
  type        = number
  default     = 1
}