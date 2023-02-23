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

###########
### k8s ###
###########

variable "k8s_version" {
  type        = string
  description = "Please enter the kubernetes version. For example: 1.24"
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

variable "media_node_size" {
  type        = string
  description = "Please enter node size for media nodes. For example: 'Standard_L8s_v3'."
}

variable "media_node_count" {
  type        = number
  description = "Please enter the number of media nodes you desire"
}

#################
### App Nodes ###
##################

variable "app_node_size" {
  type        = string
  description = "Please enter node size for media nodes. For example: 'Standard_D64_v5'."
}

variable "app_node_count" {
  type        = number
  description = "Please enter the number of application nodes you desire"
}