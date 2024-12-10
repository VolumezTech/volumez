# General Configuration
region  = "us-east-1"
resources_name_prefix = "iginor"
# num_of_zones = 2  
availability_zones = ["a", "b"]
create_fault_domain = false
avoid_pg = true
deploy_bastion = true
 
# Existing Network Configuration (Optional)
target_vpc_id             = ""
target_subnet_id          = ""
target_security_group_id  = ""
target_placement_group_id = ""
 
# Media Nodes
media_node_count = 2
media_node_type = "is4gen.2xlarge"
media_node_iam_role = null
media_node_ami = "ami-041c27b9664a43b95"
media_node_ami_username = "default"
media_node_name_prefix = "media"
 
# App Nodes
app_node_count = 1
app_node_type = "r6in.32xlarge"
app_node_iam_role = null
app_node_ami = "ami-094353d98db2c5142"
app_node_ami_username = "default"
app_node_name_prefix = "app"