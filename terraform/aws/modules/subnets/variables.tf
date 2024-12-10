variable "region" {
  default = "us-east-1"
}

variable "resources_name_prefix" {
  type    = string
  default = "volumez"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "create_pub_sn" {
  type    = bool
  default = false
}

# variable "num_of_zones" {
#   description = "Number of Availability Zones"
# }

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
}
variable "private_subnet_cidr_list" {
  description = "List of cidr blocks for each private subnet in every az"
  default     = ["10.0.85.0/24", "10.0.86.0/24", "10.0.87.0/24", "10.0.88.0/24"]
}

variable "public_subnet_cidr" {
  description = "cidr block for public subnet"
  default     = "10.0.89.0/24"
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}