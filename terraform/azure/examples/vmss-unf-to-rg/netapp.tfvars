### Resource Group ###
resource_prefix = ""
resource_group_location = "eastus"
resource_group_name = ""

### Network ###
zones = ["1"]
address_prefixes = ["10.40.1.0/26"]
nat_gateway_id = ""
proximity_placement_group_id = ""
virtual_network_name = ""
subnet_id = ""

### Storage ###
media_node_type = "Standard_L8s_v3"
media_node_count = 2

### VM Image ###
media_image_publisher = "Canonical"
media_image_offer = "0001-com-ubuntu-server-jammy" 
media_image_sku = "22_04-lts-gen2"
media_image_version = "latest"
