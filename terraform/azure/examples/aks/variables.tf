###############
### Network ###
###############

variable "resource_group_location" {
  type        = string
  default     = "East US"
}

variable "resource_prefix" {
  type        = string
  default     = "ymaymon-aks"
}

variable "zones_list" {
  type        = list
  default     = [1]
}

variable "address_space" {
  type    = list(any)
  default = ["10.1.0.0/16"]
}

variable "address_prefixes" {
  type    = list(any)
  default = ["10.1.0.0/24"]
}

variable "ssh_key_name" {
  type    = string
  default = "automation-kp"
}

###########
### k8s ###
###########

variable "k8s_cluster_version" {
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

variable "num_of_media_node" {
  type        = number
  default     = 8
}

#################
### App Nodes ###
##################

variable "app_node_type" {
  type        = string
  default     = "Standard_D64as_v5"
}

variable "num_of_app_node" {
  type        = number
  default     = 2
}