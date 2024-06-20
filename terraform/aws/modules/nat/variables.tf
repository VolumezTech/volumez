variable "pub_sn_id" {
  description = "Target public subnet to scale the nat gateway in"
}

variable "private_sn_ids" {
  description = "List of private subnet to scale the nat gateway in"
  type        = list(string)

}

variable "vpc_id" {
  description = "vpc id"

}

variable "resources_name_prefix" {
  type    = string
  default = "volumez"
}