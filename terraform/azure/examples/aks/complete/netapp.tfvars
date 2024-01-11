###  Resource Group ###
resource_prefix = ""  // Prefix for naming the resource group
resource_group_location = "eastus"  // Location of the resource group

###  Network ###
zones = ["1"]  // Availability zones for the network
address_space = ["10.40.0.0/16"]  // IP address space for the network
address_prefixes = ["10.40.0.0/24"]  // Subnet address prefixes for the network
app_proximity_placement_group = true  // Enable proximity placement group for application nodes

###  Storage ###
media_node_type = "Standard_L8s_v3"  // VM type for media nodes
media_node_count = 0  // Number of media nodes
media_proximity_placement_group = true  // Enable proximity placement group for media nodes
app_node_type = "Standard_D32_v5"  // VM type for application nodes
app_node_count = 1  // Number of application nodes

###  Kubernetes ###
k8s_version = "1.27"  // Version of Kubernetes


