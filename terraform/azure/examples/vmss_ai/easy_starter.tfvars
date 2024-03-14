# resource group
resource_group_prefix   = "example-resource"
resource_group_location = "East US"
# bastion
deploy_bastion                = true
bastion_subnet_address_prefix = ["10.0.8.0/26"]
# ssh
ssh_username = "adminuser"
# virtual network
vnet_address_space = ["10.0.0.0/16"]
subnet_count       = 8
# Avilability set 
availability_set_fault_domain_count  = 1
availability_set_update_domain_count = 1
# App VMSS
app_vmss_instances          = 1
app_vmss_instance_size      = "Standard_D64_v5"
app_vmss_fault_domain_count = 1
app_image_publisher         = "Canonical"
app_image_offer             = "0001-com-ubuntu-server-focal"
app_image_sku               = "20_04-lts"
app_image_version           = "latest"
# Media VM
media_vm_count        = 8
media_vm_size         = "Standard_L8s_v3"
media_image_publisher = "Canonical"
media_image_offer     = "0001-com-ubuntu-server-focal"
media_image_sku       = "20_04-lts"
media_image_version   = "latest"
# Volumez
tenant_token  = ""
signup_domain = "signup.volumez.com"
