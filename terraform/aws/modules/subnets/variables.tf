variable "region" {
    default     = "us-east-1"
}

variable "vpc_id" {
    description = "vpc id"
}

variable "subnet_cidr_list" {
    description = "List of cidr blocks for each subnet in every az"
    default     = ["10.0.85.0/24", "10.0.86.0/24", "10.0.87.0/24", "10.0.88.0/24"]
}

variable "map_public_ip_on_launch" {
    description = "Should be false if you do not want to auto-assign public IP on launch"
    type        = bool  
    default     = true
}