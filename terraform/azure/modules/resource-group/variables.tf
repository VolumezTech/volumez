variable "resource_prefix" {
  type    = string
  default = "default"
}

variable "random_string" {
  type = string
}

variable "resource_group_location" {
  type    = string
  default = "East US"
}

variable "address_space" {
  type    = list(any)
  default = ["10.1.0.0/16"]
}

variable "address_prefixes" {
  type    = list(any)
  default = ["10.1.0.0/24"]
}

variable "resource_group_lock_level" {
  type    = string
  default = "CanNotDelete"
}