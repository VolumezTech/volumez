# General Configuration
region  = "us-east-1"
resources_name_suffix = ""
num_of_zones = 1
create_fault_domain = true

# Keys
key_name = ""
path_to_pem = ""
tenant_token = ""

# Media Nodes
media_node_count = 7
media_node_type = "is4gen.2xlarge"
media_node_iam_role = null
media_node_ami = "default"
media_node_ami_username = "default"
media_node_name_prefix = "media"

# App Nodes
app_node_count = 0
app_node_type = "m5n.xlarge"
app_node_iam_role = null
app_node_ami = "default"
app_node_ami_username = "default"
app_node_name_prefix = "app"
