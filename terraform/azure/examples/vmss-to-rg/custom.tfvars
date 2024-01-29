### Resource Group ###
resource_prefix = "" 
target_resource_group_location = "eastus"
target_resource_group_name = ""

### Network ###
zones = ["1"]
target_proximity_placement_group_id = null
target_virtual_network_name = ""
target_subnet_id = null

### Media ###
media_node_type = "Standard_L8s_v3"
media_node_count = 2
media_image_publisher = "Canonical"
media_image_offer = "0001-com-ubuntu-server-jammy" 
media_image_sku = "22_04-lts-gen2"
media_image_version = "latest"

### Tenant Token (JWT Access Token) - Can retreive from Volumez portal under Developer Info ###
vlz_tenant_token = ""