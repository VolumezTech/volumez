variable "resources_name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "availability_zone" {
  description = "Full availability zone name for both subnets (example: us-west-2a). All cluster nodes must share one AZ."
  type        = string
}

variable "mgmt_vpc_cidr" {
  description = "Management VPC CIDR (nodes' eth0)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "mgmt_subnet_cidr" {
  description = "Management subnet CIDR (must be within mgmt_vpc_cidr)"
  type        = string
  default     = "10.0.80.0/24"
}

variable "service_vpc_cidr" {
  description = "Service network VPC CIDR (nodes' eth1)"
  type        = string
  default     = "192.168.0.0/16"
}

variable "service_subnet_cidr" {
  description = "Service network subnet CIDR — cluster node IPs are allocated from here (must be within service_vpc_cidr)"
  type        = string
  default     = "192.168.100.0/24"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to reach the management network from outside (SSH and cluster UIs). Example: [\"203.0.113.7/32\"]"
  type        = list(string)
}

variable "assign_public_ips" {
  description = "Assign public IPs on the management subnet (direct SSH; set false if you reach the nodes over private connectivity)"
  type        = bool
  default     = true
}

variable "create_bpa_exclusion" {
  description = "Create a VPC Block Public Access exclusion for the management VPC (needed when the account enforces VPC BPA and assign_public_ips is true)"
  type        = bool
  default     = true
}
