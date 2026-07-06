variable "num_of_nodes" {
  description = "Number of nodes in this group"
  type        = number
}

variable "hostname_prefix" {
  description = "Node hostname prefix; nodes are named <prefix>-0, <prefix>-1, ..."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the nodes"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "mgmt_subnet_id" {
  description = "Management subnet for eth0"
  type        = string
}

variable "mgmt_sg_id" {
  description = "Security group for eth0"
  type        = string
}

variable "service_subnet_id" {
  description = "Service network subnet for eth1"
  type        = string
}

variable "service_sg_id" {
  description = "Security group for eth1"
  type        = string
}

variable "service_subnet_cidr" {
  description = "Service network subnet CIDR that static IPs are computed from"
  type        = string
}

variable "service_ip_start" {
  description = "Host offset of the first node's service IP within service_subnet_cidr (media: 4, gateways: 50)"
  type        = number
}

variable "assign_public_ip" {
  description = "Assign a public IP on eth0"
  type        = bool
  default     = true
}

variable "placement_group_name" {
  description = "Cluster placement group name; empty string skips placement-group pinning"
  type        = string
  default     = ""
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size (gp3), in GB"
  type        = number
  default     = 100
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach; empty string attaches none (recent Volumez installs stage credentials automatically and need no instance profile)"
  type        = string
  default     = ""
}

variable "use_elastic_ip" {
  description = "Attach an Elastic IP to each node's management interface so the public IP survives stop/start. Only applies when assign_public_ip is true."
  type        = bool
  default     = true
}
