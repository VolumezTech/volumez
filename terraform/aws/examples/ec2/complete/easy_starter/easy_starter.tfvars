# General Configuration
region  = "us-east-1"
resources_name_prefix = "volumez"
num_of_zones = 1
create_fault_domain = false
avoid_pg = true
deploy_bastion = true
key_name = ""
 
# Existing Network Configuration (Optional)
target_vpc_id             = ""
target_subnet_id          = ""
target_security_group_id  = ""
target_placement_group_id = ""
 
# Media Nodes
media_node_count = 2
media_node_type = "i4i.2xlarge"
media_node_iam_role = null
media_node_ami = "default"
media_node_ami_username = "default"
media_node_name_prefix = "media"
 
# App Nodes
app_node_count = 1
app_node_type = "m5n.xlarge"
app_node_iam_role = null
app_node_ami = "default"
app_node_ami_username = "default"
app_node_name_prefix = "app"