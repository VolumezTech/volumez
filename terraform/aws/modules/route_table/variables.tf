variable "vpc_id" {
  description = "Vpc id"
}

variable "default_rtb_id" {
  description = "Default route table id"
}

variable "destination_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}