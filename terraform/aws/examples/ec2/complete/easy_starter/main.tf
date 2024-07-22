terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22.0"
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
  create_vpc      = var.target_vpc_id == "" ? true : false
  create_sn       = var.target_subnet_id == "" ? true : false
  create_pg       = var.target_placement_group_id == "" && var.avoid_pg == false ? true : false
  deploy_bastion  = var.target_subnet_id == "" ? var.deploy_bastion : false
  resource_prefix = "${var.resources_name_prefix}-${random_string.random.result}"
  create_ssh_key  = var.key_name == "" ? true : false
}

module "ssh_key" {
  source = "../../../../modules/ssh_key"
  count  = local.create_ssh_key ? 1 : 0
}

module "vpc" {
  source = "../../../../modules/vpc"
  count  = local.create_vpc ? 1 : 0

  resources_name_prefix = local.resource_prefix
}

module "route_table" {
  source = "../../../../modules/route_table"
  count  = local.create_vpc ? 1 : 0

  vpc_id         = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  default_rtb_id = local.create_vpc ? module.vpc[0].default_rtb_id : ""

  depends_on = [
    module.vpc
  ]
}

module "security_group" {
  source = "../../../../modules/security_group"
  count  = local.create_vpc ? 1 : 0

  vpc_id                = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  resources_name_prefix = local.resource_prefix

  depends_on = [
    module.vpc
  ]
}

module "subnets" {
  source = "../../../../modules/subnets"
  count  = local.create_sn ? 1 : 0

  vpc_id                = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  region                = var.region
  num_of_zones          = var.num_of_zones
  resources_name_prefix = local.resource_prefix

  depends_on = [
    module.vpc
  ]
}

module "nat" {
  source = "../../../../modules/nat"
  count  = local.create_sn ? 1 : 0

  vpc_id                = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  pub_sn_id             = module.subnets[0].public_sn_id
  private_sn_ids        = module.subnets[0].private_sn_ids
  resources_name_prefix = local.resource_prefix

  depends_on = [module.vpc, module.subnets]

}

module "placement_group" {
  source = "../../../../modules/placement_group"
  count  = local.create_pg ? 1 : 0

  num_of_zones             = var.num_of_zones
  vpc_id                   = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  node_count               = var.media_node_count
  placement_group_strategy = var.create_fault_domain ? "partition" : "cluster"

  depends_on = [
    module.vpc
  ]
}

module "network_interfaces_app_nodes" {
  source = "../../../../modules/network_interface"

  num_of_nodes   = var.app_node_count
  vpc_id         = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  num_of_zones   = var.num_of_zones
  private_sn_ids = local.create_sn ? module.subnets[0].private_sn_ids : [var.target_subnet_id]
  env_sg_id      = local.create_vpc ? module.security_group[0].sg_id : var.target_security_group_id


  depends_on = [
    module.vpc,
    module.route_table,
    module.security_group,
    module.subnets
  ]
}

module "network_interfaces_media_nodes" {
  source = "../../../../modules/network_interface"

  num_of_nodes   = var.media_node_count
  vpc_id         = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  num_of_zones   = var.num_of_zones
  private_sn_ids = local.create_sn ? module.subnets[0].private_sn_ids : [var.target_subnet_id]
  env_sg_id      = local.create_vpc ? module.security_group[0].sg_id : var.target_security_group_id
  start_ip       = (10 + var.app_node_count)

  depends_on = [
    module.vpc,
    module.route_table,
    module.security_group,
    module.subnets,
    module.network_interfaces_app_nodes
  ]
}

module "app_nodes" {
  source = "../../../../modules/nodes"

  num_of_nodes          = var.app_node_count
  num_of_zones          = var.num_of_zones
  vpc_id                = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  placement_group_ids   = local.create_pg ? module.placement_group[0].placement_group_ids : [var.target_placement_group_id]
  ami_id                = var.app_node_ami
  ami_username          = var.app_node_ami_username
  iam_role              = var.app_node_iam_role
  node_type             = var.app_node_type
  key_name              = local.create_ssh_key ? module.ssh_key[0].key_name : var.key_name
  pub_eni_list          = module.network_interfaces_app_nodes.nodes_eni_ids
  path_to_pem           = var.path_to_pem
  tenant_token          = var.tenant_token
  app_node_name_prefix  = var.app_node_name_prefix
  signup_domain         = var.signup_domain
  resources_name_prefix = local.resource_prefix

  depends_on = [
    module.vpc,
    module.network_interfaces_app_nodes,
    module.ssh_key
  ]
}

module "media_nodes" {
  source = "../../../../modules/nodes"

  num_of_nodes          = var.media_node_count
  num_of_zones          = var.num_of_zones
  vpc_id                = local.create_vpc ? module.vpc[0].vpc_id : var.target_vpc_id
  placement_group_ids   = local.create_pg ? module.placement_group[0].placement_group_ids : [var.target_placement_group_id]
  ami_id                = var.media_node_ami
  ami_username          = var.media_node_ami_username
  iam_role              = var.media_node_iam_role
  node_type             = var.media_node_type
  key_name              = local.create_ssh_key ? module.ssh_key[0].key_name : var.key_name
  pub_eni_list          = module.network_interfaces_media_nodes.nodes_eni_ids
  path_to_pem           = var.path_to_pem
  tenant_token          = var.tenant_token
  app_node_name_prefix  = var.media_node_name_prefix
  signup_domain         = var.signup_domain
  resources_name_prefix = local.resource_prefix

  depends_on = [
    module.vpc,
    module.network_interfaces_media_nodes,
    module.ssh_key
  ]
}

module "bastion" {
  source = "../../../../modules/bastion"
  count  = local.deploy_bastion ? 1 : 0

  vpc_id                = module.vpc[0].vpc_id
  pub_sn_id             = module.subnets[0].public_sn_id
  sg_list               = [module.security_group[0].sg_id]
  resources_name_prefix = local.resource_prefix
  key_pair              = local.create_ssh_key ? module.ssh_key[0].key_name : var.key_name

  depends_on = [
    module.vpc,
    module.route_table,
    module.security_group,
    module.subnets,
    module.network_interfaces_app_nodes
  ]
}
