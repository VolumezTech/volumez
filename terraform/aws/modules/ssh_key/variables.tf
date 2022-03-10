variable "description" {
  default     = "ssh key for Volumez"
  description = "ssh key for Volumez used to create ec2 and ssh into them"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to keypair/secret name"
  type        = string
  default     = "Volumez"
}

variable "tags" {
  default     = {}
  description = "Tags to add to supported resources"
  type        = map(string)
}
