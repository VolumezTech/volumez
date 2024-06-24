variable "bastion_ec2_type" {
  description = "bastion ec2 type"
  default     = "t2.micro"
}

variable "ami_id_bastion" {
  description = "ami id of bastion server"
  default     = "ami-0cff7528ff583bf9a"
}

variable "key_pair" {
  description = "target key pair to attach to the bastion server"
  default     = "automation-kp"
}

variable "iam_role" {
  description = "target iam role of the bastion server"
  default     = "ec2-full-access-role"
}

variable "vpc_id" {
  description = "Target vpc to scale the bastion server in"
}

variable "sg_list" {
  description = "list of security groups to attach to the bastion server"
}

variable "pub_sn_id" {
  description = "Target public subnet to scale the bastion server in"
}

variable "deployment_tag_name" {
  default = "default-tf-tag"
}

variable "private_key" {
  description = "value of the private key path"

}

variable "resources_name_prefix" {
  description = "suffix to add to the resources names"
  default     = "Volumez"

}
