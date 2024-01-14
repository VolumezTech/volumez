# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#   Create Azure Bastion Host, Subnet, Public IP 
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

// local variable, num_of_bastion - will be 0 if deploy_bastion is false, 1 if true

locals {
  num_of_bastion = var.deploy_bastion ? 1 : 0
}

resource "azurerm_network_security_group" "nsg-bastion" {
  count = local.num_of_bastion
  
  name                = "bastion-nsg"
  resource_group_name = var.rg-name
  location            = var.location

  security_rule {
    name                       = "allow_ssh_in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    # Ingress traffic from Internet on 443 is enabled
    name                       = "AllowIB_HTTPS443_Internet"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    # Ingress traffic for control plane activity that is GatewayManger to be able to talk to Azure Bastion
    name                       = "AllowIB_TCP443_GatewayManager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    # Deny all other Ingress traffic 
    name                       = "DenyIB_any_other_traffic"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # * * * * * * OUT-BOUND Traffic * * * * * * #

  # Egress traffic to the target VM subnets over ports 3389 and 22
  security_rule {
    name                       = "allow_ssh_out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Egress traffic to AzureCloud over 443
  security_rule {
    name                       = "AllowOB_AzureCloud"
    priority                   = 105
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # Egress traffic for data plane communication between the Bastion and VNets service tags
  security_rule {
    name                       = "AllowOB_BastionHost_Comn"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Egress traffic for SessionInformation
  security_rule {
    name                       = "AllowOB_GetSessionInformation"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

# Create AzureBastionSubnet
resource "azurerm_subnet" "AzureBastionSubnet" {
  count = num_of_bastion
  
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg-name
  virtual_network_name = var.tf_vnet1_name
  address_prefixes     = var.azbastion-subnet-address
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count = 
  
  subnet_id                 = azurerm_subnet.AzureBastionSubnet.id
  network_security_group_id = azurerm_network_security_group.nsg-bastion.id

  depends_on = [
    azurerm_subnet.AzureBastionSubnet,
    azurerm_network_security_group.nsg-bastion
  ]
}

# Create PublicIP for Azure Bastion
resource "azurerm_public_ip" "azb-publicIP" {
  count = num_of_bastion

  name                = "azb-publicIP"
  location            = var.location
  resource_group_name = var.rg-name
  allocation_method   = var.firewall_allocation_method
  sku                 = var.firewall_sku
}

# Create Azure Bastion Host
resource "azurerm_bastion_host" "azb-host" {
  count = num_of_bastion
  
  name                = "azb-host"
  location            = var.location
  resource_group_name = var.rg-name
  scale_units         = var.azb_scl_units

  ip_configuration {
    name                 = "azb-Ip-configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.azb-publicIP.id
  }
  tags = {
    "solution"  = "Azure Bastion Service"
    environment = var.environment
  }
}

