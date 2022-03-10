variable "vpc_id" {
    description = "vpc ids list to create the eni in"
}

variable "num_of_zones" {
    default = 1
}

variable "num_of_nodes" {
    description = "Number of nodes to create"
    type        = number
}

variable "pub_sn_ids" {
    description = "pub subnet id list"
}

variable "env_sg_id" {
    description = "security group id"
    type        = string
}

variable "start_ip" {
   description = "start ip addr"
   default     = 10
}

variable "pub_ip_cidr_tmpl" {
    default     = ["10.0.85", "10.0.86", "10.0.87", "10.0.88"] 
}