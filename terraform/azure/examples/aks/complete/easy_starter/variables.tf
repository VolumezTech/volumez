###############
### Network ###
###############

variable "resource_group_location" {
  type        = string
  default     = "East US"
  description = "Please enter the region. For example: East US"
}

variable "resource_prefix" {
  type        = string
  default     = "Volumez-easy-aks"
  description = "Please enter the cluster name prefix"
}

###########
### k8s ###
###########

variable "k8s_version" {
  type        = string
  default     = "1.24"
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

variable "media_node_type" {
  type        = string
  default     = "Standard_L8s_v3"
  description = "Please enter EC2 Instance Type for media nodes. For example: 'Standard_L8s_v3'."
}

variable "media_node_count" {
  type        = number
  default     = 6
  description = "Please enter the number of media nodes you desire"
}
