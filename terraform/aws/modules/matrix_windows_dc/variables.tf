variable "enabled" {
  description = "Create the Domain Controller"
  type        = bool
  default     = true
}

variable "hostname" {
  description = "Name tag for the DC instance"
  type        = string
  default     = "ad-dc"
}

variable "instance_type" {
  description = "EC2 instance type for the DC"
  type        = string
  default     = "m5.xlarge"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "mgmt_subnet_id" {
  description = "Management subnet (the DC has no service NIC)"
  type        = string
}

variable "mgmt_sg_id" {
  description = "Security group for the DC"
  type        = string
}

variable "assign_public_ip" {
  description = "Assign a public IP (RDP/WinRM access)"
  type        = bool
  default     = true
}

variable "admin_password" {
  description = "Local Administrator password, set via user-data (RDP/WinRM login)"
  type        = string
  sensitive   = true
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size (gp3, encrypted), in GB"
  type        = number
  default     = 256
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach; empty string attaches none"
  type        = string
  default     = ""
}
