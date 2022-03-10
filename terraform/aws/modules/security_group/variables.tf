variable "vpc_id" {
    description = "vpc id"
}

variable "ingress_cidr_block" {
    type    = list
    default = [ "0.0.0.0/0" ]
}