###############
### General ###
###############

variable "region" {
  description = "AWS region to create the environment in"
  type        = string
  default     = "us-west-2"
}

variable "target_az" {
  description = "Availability zone letter within the region (all cluster nodes share one AZ)"
  type        = string
  default     = "a"
}

variable "resources_name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "VolumezMatrix"
}

###############
### Network ###
###############

variable "mgmt_vpc_cidr" {
  description = "Management VPC CIDR (nodes' eth0)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "mgmt_subnet_cidr" {
  description = "Management subnet CIDR"
  type        = string
  default     = "10.0.80.0/24"
}

variable "service_vpc_cidr" {
  description = "Service network VPC CIDR (nodes' eth1, cluster traffic)"
  type        = string
  default     = "192.168.0.0/16"
}

variable "service_subnet_cidr" {
  description = "Service network subnet CIDR. Media node IPs are allocated at .4+index and gateway IPs at .50+index within this subnet — coordinate with Volumez before changing it."
  type        = string
  default     = "192.168.100.0/24"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to reach the management network from outside (SSH, RDP/WinRM, cluster UIs). Default is open to the entire internet — fine for a short-lived, key-only test environment; narrow it to your operators' networks + the network Volumez connects from for anything longer-lived."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "iam_instance_profile_name" {
  description = "Optional IAM instance profile name to attach to all nodes (minimum: secretsmanager:GetSecretValue on matrix/* secrets). Leave empty for none — recent Volumez installs stage artifact credentials automatically and require no instance profile."
  type        = string
  default     = ""
}

variable "assign_public_ips" {
  description = "Assign public IPs to the nodes' management interface (direct SSH). Set false only if you reach the nodes over private connectivity (VPN/DirectConnect)."
  type        = bool
  default     = true
}

variable "create_bpa_exclusion" {
  description = "Create a VPC Block Public Access exclusion for the management VPC (needed when the AWS account enforces VPC BPA and assign_public_ips is true)"
  type        = bool
  default     = true
}

variable "avoid_pg" {
  description = "Skip the cluster placement group (set true if AZ capacity prevents placement)"
  type        = bool
  default     = false
}

############
### Keys ###
############

variable "key_name" {
  description = "Name of an existing EC2 key pair to use for the nodes; if not set, a new key pair is generated (private key available via the sensitive ssh_private_key output)"
  type        = string
  default     = ""
}

###################
### Media Nodes ###
###################

variable "media_node_count" {
  description = "Number of media (DAOS storage) nodes"
  type        = number
  default     = 5
}

variable "media_node_type" {
  description = "EC2 instance type for media nodes. Must provide local NVMe instance-store (r8idn/r8id/i4i families) — the storage tier requires a raw second disk. Capacity note: 5-node r8idn.32xlarge clusters are capacity-confirmed in us-west-2a only (r8id.32xlarge: us-west-2a/c/d)."
  type        = string
  default     = "r8idn.32xlarge"
}

variable "media_node_ami" {
  description = "AMI for media nodes. Default is the Volumez-validated Rocky Linux 10 image in us-west-2 (shared to your AWS account by Volumez; default SSH user: ec2-user). Set to \"default\" to use the latest official Rocky Linux 10 image instead (SSH user: rocky) — media nodes must run Rocky Linux 10 either way."
  type        = string
  default     = "ami-07ae209e04e1dceaf"
}

variable "media_node_name_prefix" {
  description = "Hostname prefix for media nodes"
  type        = string
  default     = "media"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size (gp3), in GB, for all nodes"
  type        = number
  default     = 100
}

#####################
### Gateway Nodes ###
#####################

variable "gateway_node_count" {
  description = "Number of gateway nodes (optional; protocol/access-layer nodes)"
  type        = number
  default     = 0
}

variable "gateway_node_type" {
  description = "EC2 instance type for gateway nodes"
  type        = string
  default     = "i4i.4xlarge"
}

variable "gateway_node_ami" {
  description = "AMI for gateway nodes. Default is the Volumez-validated Rocky Linux 10 image in us-west-2; \"default\" selects the latest official Rocky Linux 10 image instead"
  type        = string
  default     = "ami-07ae209e04e1dceaf"
}

variable "gateway_node_name_prefix" {
  description = "Hostname prefix for gateway nodes"
  type        = string
  default     = "gateway"
}

####################
### Linux Client ###
####################

variable "client_node_count" {
  description = "Number of Linux client (load generator) nodes"
  type        = number
  default     = 1
}

variable "client_node_type" {
  description = "EC2 instance type for the Linux client"
  type        = string
  default     = "m6i.4xlarge"
}

variable "client_node_ami" {
  description = "AMI for the Linux client; \"default\" selects the latest official RHEL 10 image (SSH user: ec2-user)"
  type        = string
  default     = "default"
}

variable "client_node_name_prefix" {
  description = "Hostname prefix for client nodes"
  type        = string
  default     = "client"
}

#########################
### Domain Controller ###
#########################

variable "enable_ad_dc" {
  description = "Create the Active Directory Domain Controller (Windows Server 2022, management network only)"
  type        = bool
  default     = true
}

variable "ad_dc_instance_type" {
  description = "EC2 instance type for the Domain Controller"
  type        = string
  default     = "m5.xlarge"
}

variable "ad_admin_password" {
  description = "Local Administrator password for the Domain Controller (required when enable_ad_dc is true; RDP/WinRM login)"
  type        = string
  sensitive   = true
  default     = ""
}
