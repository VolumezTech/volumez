variable "vpc_id" {
    description = "vpc id"
}

variable "num_of_zones" {
    default = 1
}

variable "pub_eni_list" {
    description = "pub network interfaces list"
}

variable "placement_group_ids" {
    default = [""]
}

variable "num_of_nodes" {
    type    = number
    default = 5
}

variable "node_type" {
    type    = string
    default = "i3.large"
}

variable "ami_id" {
    description = "If not set - latest Red Hat 8.5 will be used as default"
    type        = string
    default     = ""
}

variable "ami_username" {
    description = "The username to use for the connection for specified ami"
    type        = string
    default     = ""
}

variable "key_name" {
    type    = string
}

variable "path_to_pem" {
    type    = string
    default = ""
}

variable "key_value" {
    type    = string
    default = ""
}

variable "iam_role" {
    description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
    type        = string
    default     = "null"
}

variable "app_node_name_prefix" {
    type    = string
    default = "node"
}

variable "node_name_prefix" {
    type    = string
    default = "default"
}

variable "tenant_token" {
    description = "Tenant token to access Cognito and pull the connector"
    type        = string
}