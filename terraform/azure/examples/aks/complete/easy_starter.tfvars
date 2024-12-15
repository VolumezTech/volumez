subscription_id = "453b58fc-f031-4f46-9d1a-b35f725143f4"  // Please enter the subscription id

###  Resource Group ###
resource_prefix = "Volumez"  // Prefix for naming the resource group
resource_group_location = "eastus"  // Location of the resource group

###  Network ###
zones = ["1"]  // Availability zones for the network
address_space = ["10.40.0.0/16"]  // IP address space for the network
address_prefixes = ["10.40.0.0/24"]  // Subnet address prefixes for the network

###  App Nodes ###
app_proximity_placement_group = true  // Enable proximity placement group for app nodes
app_node_type = "Standard_D32_v5"  // VM type for application nodes
app_node_count = 1  // Number of application nodes

###  Media Nodes ###
media_proximity_placement_group = true  // Enable proximity placement group for media nodes
media_node_type = "Standard_L8s_v3"  // VM type for media nodes
media_node_count = 6  // Number of media nodes

###  Kubernetes ###
k8s_version = "1.30"  // Version of Kubernetes
deploy_bastion = false  // Deploy a bastion host
