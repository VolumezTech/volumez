provider "aws" {
    region = var.region
}

data "aws_vpc" "selected" {
    id = var.vpc_id
}

locals {
  num_of_zones   = length(var.subnet_id_list)
  default_rtb_id = data.aws_vpc.selected.main_route_table_id
}

module "placement_group" {
    source = "../../../../modules/placement_group"

    num_of_zones             = local.num_of_zones
    vpc_id                   = data.aws_vpc.selected.id
    placement_group_strategy = var.placement_group_strategy
}

module "network_interfaces_app_nodes" {
    source = "../../../../modules/network_interface"

    num_of_nodes = var.app_node_count
    vpc_id       = data.aws_vpc.selected.id
    num_of_zones = local.num_of_zones
    pub_sn_ids   = var.subnet_id_list
    env_sg_id    = var.security_group_id
}

module "network_interfaces_media_nodes" {
    source = "../../../../modules/network_interface"

    num_of_nodes = var.media_node_count
    vpc_id       = data.aws_vpc.selected.id
    num_of_zones = local.num_of_zones
    pub_sn_ids   = var.subnet_id_list
    env_sg_id    = var.security_group_id
    start_ip     = (10 + var.app_node_count)
    
    depends_on = [
        module.network_interfaces_app_nodes
    ]
}

module "ssh_key" {
    source = "../../../../modules/ssh_key"
}

module "app_nodes" {
    source = "../../../../modules/nodes"

    num_of_nodes         = var.app_node_count    
    num_of_zones         = local.num_of_zones
    vpc_id               = data.aws_vpc.selected.id
    placement_group_ids  = module.placement_group.placement_group_ids    
    ami_id               = var.app_node_ami
    ami_username         = var.app_node_ami_username
    iam_role             = var.app_node_iam_role
    node_type            = var.app_node_type
    key_name             = var.key_name == "" ? module.ssh_key.key_name : var.key_name
    key_value            = var.key_name == "" ? module.ssh_key.key_value : ""
    pub_eni_list         = module.network_interfaces_app_nodes.pub_nodes_eni_ids
    path_to_pem          = var.path_to_pem
    tenant_token         = var.tenant_token
    app_node_name_prefix = var.app_node_name_prefix
    signup_domain        = var.signup_domain

    depends_on = [
        module.network_interfaces_app_nodes,
        module.ssh_key
    ]
}

module "media_nodes" {
    source = "../../../../modules/nodes"

    num_of_nodes         = var.media_node_count
    num_of_zones         = local.num_of_zones
    vpc_id               = data.aws_vpc.selected.id
    placement_group_ids  = module.placement_group.placement_group_ids
    ami_id               = var.media_node_ami
    ami_username         = var.media_node_ami_username
    iam_role             = var.media_node_iam_role
    node_type            = var.media_node_type
    key_name             = var.key_name == "" ? module.ssh_key.key_name : var.key_name
    key_value            = var.key_name == "" ? module.ssh_key.key_value : ""
    pub_eni_list         = module.network_interfaces_media_nodes.pub_nodes_eni_ids
    path_to_pem          = var.path_to_pem
    tenant_token         = var.tenant_token
    app_node_name_prefix = var.media_node_name_prefix
    signup_domain        = var.signup_domain   

    depends_on = [
        module.network_interfaces_media_nodes,
        module.ssh_key
    ]
}