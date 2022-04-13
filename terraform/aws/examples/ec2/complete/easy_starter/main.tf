provider "aws" {
    region = var.region
}

module "vpc" {
    source = "../../modules/vpc"
}

module "route_table" {
    source         = "../../modules/route_table"

    vpc_id         = module.vpc.vpc_id
    default_rtb_id = module.vpc.default_rtb_id

    depends_on = [
      module.vpc
    ]
}

module "security_group" {
    source = "../../modules/security_group"
    
    vpc_id = module.vpc.vpc_id

    depends_on = [
      module.vpc
    ]
}

module "subnets" {
    source      = "../../modules/subnets"

    region       = var.region
    vpc_id       = module.vpc.vpc_id
    num_of_zones = var.num_of_zones

    depends_on = [
      module.vpc
    ]
}

module "placement_group" {
    source                   = "../../modules/placement_group"

    num_of_zones             = var.num_of_zones
    vpc_id                   = module.vpc.vpc_id
    placement_group_strategy = var.placement_group_strategy

    depends_on = [
        module.vpc
    ]
}

module "network_interfaces_app_nodes" {
    source = "../../modules/network_interface"

    num_of_nodes = var.app_node_count
    vpc_id       = module.vpc.vpc_id
    num_of_zones = var.num_of_zones
    pub_sn_ids   = module.subnets.pub_sn_ids
    env_sg_id    = module.security_group.sg_id
    

    depends_on = [
        module.vpc,
        module.route_table,
        module.security_group, 
        module.subnets
    ]
}

module "network_interfaces_media_nodes" {
    source = "../../modules/network_interface"

    num_of_nodes = var.media_node_count
    vpc_id       = module.vpc.vpc_id
    num_of_zones = var.num_of_zones
    pub_sn_ids   = module.subnets.pub_sn_ids
    env_sg_id    = module.security_group.sg_id
    start_ip     = (10 + var.app_node_count)
    
    depends_on = [
        module.vpc, 
        module.route_table,
        module.security_group, 
        module.subnets, 
        module.network_interfaces_app_nodes
    ]
}

module "ssh_key" {
    source = "../../modules/ssh_key"
}

module "app_nodes" {
    source = "../../modules/nodes"


    num_of_nodes         = var.app_node_count    
    num_of_zones         = var.num_of_zones
    vpc_id               = module.vpc.vpc_id
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
        module.vpc, 
        module.network_interfaces_app_nodes,
        module.ssh_key
    ]
}

module "media_nodes" {
    source = "../../modules/nodes"

    num_of_nodes         = var.media_node_count
    num_of_zones         = var.num_of_zones
    vpc_id               = module.vpc.vpc_id
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
        module.vpc, 
        module.network_interfaces_media_nodes,
        module.ssh_key
    ]
}