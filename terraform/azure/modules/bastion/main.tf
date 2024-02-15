# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#   Create Azure Bastion Host, Subnet, Public IP 
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

# Create AzureBastionSubnet
resource "azurerm_subnet" "AzureBastionSubnet" {
  
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg-name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.azbastion-subnet-address
}


# Create PublicIP for Azure Bastion
resource "azurerm_public_ip" "azb-publicIP" {

  name                = "azb-publicIP"
  location            = var.location
  resource_group_name = var.rg-name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Azure Bastion Host
resource "azurerm_bastion_host" "azb-host" {
  
  name                = "azb-host"
  location            = var.location
  resource_group_name = var.rg-name

  ip_configuration {
    name                 = "azb-Ip-configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.azb-publicIP.id
  }
  tags = {
    "solution"  = "Azure Bastion Service"
  }
}