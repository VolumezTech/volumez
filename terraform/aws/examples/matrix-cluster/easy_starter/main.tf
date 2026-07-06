# Volumez Matrix cluster environment (AWS)
#
# Provisions the environment shape the Volumez Matrix installation expects:
#   - Dual VPC / dual NIC: management network (eth0, public SSH) + isolated
#     service network (eth1, static IPs) for all cluster traffic.
#   - Media (DAOS storage) nodes: Rocky Linux 10, NVMe instance-store types
#     (i4i family), service IPs 192.168.100.4, .5, .6, ... in order.
#   - Optional gateway nodes: service IPs 192.168.100.50, .51, ... in order.
#
# After `terraform apply`, copy the `custom_ips_csv` output and hand it to
# Volumez — it is the exact node mapping the Matrix installation consumes.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # aws_vpc_block_public_access_exclusion requires >= 5.80
      version = ">= 5.80"
    }
  }
  required_version = ">= 1.3.5"
}

provider "aws" {
  region = var.region
}

resource "random_string" "random" {
  length  = 5
  special = false
}

locals {
  resource_prefix = "${var.resources_name_prefix}-${random_string.random.result}"
  create_ssh_key  = var.key_name == "" ? true : false
  create_pg       = var.avoid_pg == false ? true : false

  media_ami   = var.media_node_ami == "default" ? data.aws_ami.rocky10.id : var.media_node_ami
  gateway_ami = var.gateway_node_ami == "default" ? data.aws_ami.rocky10.id : var.gateway_node_ami
  client_ami  = var.client_node_ami == "default" ? data.aws_ami.rhel10.id : var.client_node_ami

  key_name = local.create_ssh_key ? module.ssh_key[0].key_name : var.key_name

  # Cluster nodes (media + gateways) get the VIP instance profile: an
  # explicit iam_instance_profile_name wins, else the profile created here.
  create_iam       = var.iam_instance_profile_name == "" && var.create_iam_instance_profile
  cluster_node_iam = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : (local.create_iam ? aws_iam_instance_profile.cluster_node[0].name : "")
}

# Official Rocky Linux 10 AMI (Rocky Enterprise Software Foundation).
# Media nodes MUST run Rocky Linux 10 — the Matrix readiness check enforces it.
data "aws_ami" "rocky10" {
  most_recent = true
  owners      = ["792107900819"]

  filter {
    name   = "name"
    values = ["Rocky-10-EC2-Base-10*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Official RHEL 10 AMI (Red Hat) — default image for the Linux client
data "aws_ami" "rhel10" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-10*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "ssh_key" {
  source = "../../../modules/ssh_key"
  count  = local.create_ssh_key ? 1 : 0
}

module "network" {
  source = "../../../modules/matrix_network"

  resources_name_prefix = local.resource_prefix
  availability_zone     = "${var.region}${var.target_az}"
  mgmt_vpc_cidr         = var.mgmt_vpc_cidr
  mgmt_subnet_cidr      = var.mgmt_subnet_cidr
  service_vpc_cidr      = var.service_vpc_cidr
  service_subnet_cidr   = var.service_subnet_cidr
  allowed_ssh_cidrs     = var.allowed_ssh_cidrs
  assign_public_ips     = var.assign_public_ips
  create_bpa_exclusion  = var.create_bpa_exclusion
}

# Minimal IAM instance profile for the cluster's floating IPs (HA VIPs).
# On AWS, Pacemaker's awsvip agent must register a moving VIP with the VPC
# via the EC2 API — these four permissions are all it needs. Artifact
# downloads need NO node credentials (the Volumez install stages those).
# Set create_iam_instance_profile = false and/or iam_instance_profile_name
# to bring your own role instead.
resource "aws_iam_role" "cluster_node" {
  count = local.create_iam ? 1 : 0

  name = "${local.resource_prefix}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name      = "${local.resource_prefix}-node-role"
    Terraform = "true"
  }
}

resource "aws_iam_role_policy" "cluster_vip" {
  count = local.create_iam ? 1 : 0

  name = "${local.resource_prefix}-vip"
  role = aws_iam_role.cluster_node[0].id
  # ENI ARNs don't exist before apply, so the resource scope is "*";
  # the actions are limited to what VIP failover requires.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeInstances"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "cluster_node" {
  count = local.create_iam ? 1 : 0

  name = "${local.resource_prefix}-node-profile"
  role = aws_iam_role.cluster_node[0].name
}

# Cluster placement group: keeps node-to-node latency low. Requires capacity
# for all nodes in one AZ — set avoid_pg = true if placement fails.
resource "aws_placement_group" "cluster" {
  count = local.create_pg ? 1 : 0

  name     = "${local.resource_prefix}-pg"
  strategy = "cluster"

  tags = {
    Name      = "${local.resource_prefix}-pg"
    Terraform = "true"
  }
}

# Media (DAOS storage) nodes — service IPs 192.168.100.4 + index
module "media_nodes" {
  source = "../../../modules/matrix_node"

  num_of_nodes         = var.media_node_count
  hostname_prefix      = var.media_node_name_prefix
  ami_id               = local.media_ami
  instance_type        = var.media_node_type
  key_name             = local.key_name
  mgmt_subnet_id       = module.network.mgmt_subnet_id
  mgmt_sg_id           = module.network.mgmt_sg_id
  service_subnet_id    = module.network.service_subnet_id
  service_sg_id        = module.network.service_sg_id
  service_subnet_cidr  = var.service_subnet_cidr
  service_ip_start     = 4 # AWS reserves .0-.3; the install expects media at .4+
  assign_public_ip     = var.assign_public_ips
  placement_group_name = local.create_pg ? aws_placement_group.cluster[0].name : ""
  root_volume_size_gb  = var.root_volume_size_gb
  iam_instance_profile = local.cluster_node_iam
}

# Optional gateway nodes — service IPs 192.168.100.50 + index
module "gateway_nodes" {
  source = "../../../modules/matrix_node"

  num_of_nodes         = var.gateway_node_count
  hostname_prefix      = var.gateway_node_name_prefix
  ami_id               = local.gateway_ami
  instance_type        = var.gateway_node_type
  key_name             = local.key_name
  mgmt_subnet_id       = module.network.mgmt_subnet_id
  mgmt_sg_id           = module.network.mgmt_sg_id
  service_subnet_id    = module.network.service_subnet_id
  service_sg_id        = module.network.service_sg_id
  service_subnet_cidr  = var.service_subnet_cidr
  service_ip_start     = 50 # the install expects gateways at .50+
  assign_public_ip     = var.assign_public_ips
  placement_group_name = local.create_pg ? aws_placement_group.cluster[0].name : ""
  root_volume_size_gb  = var.root_volume_size_gb
  iam_instance_profile = local.cluster_node_iam
}

# Optional Linux client (load generator) — service IP 192.168.100.210+,
# dual-NIC like the cluster nodes but NOT in the placement group
module "client_nodes" {
  source = "../../../modules/matrix_node"

  num_of_nodes         = var.client_node_count
  hostname_prefix      = var.client_node_name_prefix
  ami_id               = local.client_ami
  instance_type        = var.client_node_type
  key_name             = local.key_name
  mgmt_subnet_id       = module.network.mgmt_subnet_id
  mgmt_sg_id           = module.network.mgmt_sg_id
  service_subnet_id    = module.network.service_subnet_id
  service_sg_id        = module.network.service_sg_id
  service_subnet_cidr  = var.service_subnet_cidr
  service_ip_start     = 210 # clients sit at .210+
  assign_public_ip     = var.assign_public_ips
  placement_group_name = ""
  root_volume_size_gb  = var.root_volume_size_gb
  iam_instance_profile = var.iam_instance_profile_name # clients host no VIPs
}

# Optional Active Directory Domain Controller — management network only
module "ad_dc" {
  source = "../../../modules/matrix_windows_dc"

  enabled              = var.enable_ad_dc
  hostname             = "${local.resource_prefix}-ad-dc"
  instance_type        = var.ad_dc_instance_type
  key_name             = local.key_name
  mgmt_subnet_id       = module.network.mgmt_subnet_id
  mgmt_sg_id           = module.network.mgmt_sg_id
  assign_public_ip     = var.assign_public_ips
  admin_password       = var.ad_admin_password
  iam_instance_profile = var.iam_instance_profile_name
}
