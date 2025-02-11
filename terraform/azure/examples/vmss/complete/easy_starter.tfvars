subscription_id = ""  // Please enter the subscription id

#### Resource Group ###
### IMPORTANT: If you wish to create a VMSS in a new resource group, you must set the resource_group_location and resource_prefix. 
### If you wish to use an existing resource group, you must set the target_resource_group_location and target_resource_group_name.
### Do not set both resource_group and target_resource_group. 1 or 2 ####

### 1.Create Resource Group (if set will create a new resource group for this VMSS)###
resource_group_location = "eastus"
resource_prefix = "volumez"

### 2.Target Resource Group (create the VMSS in an existing resource group) ###
target_resource_group_location = ""
target_resource_group_name = ""

### VMSS ###
vmss_type = "flexible" # "uniform" or "flexible"
create_fault_domain = true 
## platform_fault_domain_count:
# 1. if vmss_type = "uniform/flexible" and create_fault_domain = false, platform_fault_domain_count will be 1
# 2. if vmss_type = "uniform" and create_fault_domain = true, platform_fault_domain_count will be 5
# 3. if vmss_type = "flexible" and create_fault_domain = true, platform_fault_domain_count can be 2 or 3 (set in variable below)
# 4. if vmss_type = "flexible" and create_fault_domain = true and Microsoft.Compute/VMOrchestratorZonalMultiFD is enabled, platform_fault_domain_count can be 2-5 (set in variable below)
platform_fault_domain_count = 5


### Network ###
# if setting more than 1 zone, no proximity_placement_group will be created/used
# if setting more than 1 zone and vmss_type="uniform", platform_fault_domain_count will be 5
zones = ["1", "2"] 
target_proximity_placement_group_id = null
target_virtual_network_name = ""
target_subnet_id = null
deploy_bastion = false

### Media ###
media_node_type = "Standard_L8s_v3"
media_node_count = 20   
media_image_publisher = "Canonical"
media_image_offer = "0001-com-ubuntu-server-jammy" 
media_image_sku = "22_04-lts-gen2"
media_image_version = "latest"

### CSI Driver Token (JWT Access Token) - Can retreive from Volumez portal under Developer Info ###
vlz_refresh_token = ""
