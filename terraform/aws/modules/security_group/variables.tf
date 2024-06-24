variable "vpc_id" {
  description = "vpc id"
}

variable "ingress_cidr_block" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "resources_name_prefix" {
  type    = string
  default = "volumez"

}