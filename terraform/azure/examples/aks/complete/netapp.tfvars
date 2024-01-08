resource_prefix = "ig-na-aks"
resource_group_location = "eastus"
zones = ["1"]
media_node_type = "Standard_L8s_v3"
media_node_count = 0
media_proximity_placement_group = true
app_node_type = "Standard_E104i_v5"
app_node_count = 1
app_proximity_placement_group = true
k8s_version = "1.27"

