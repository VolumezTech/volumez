resource "azurerm_resource_group" "this" {
  name     = "${var.resource_prefix}-${var.random_string}-rg"
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.resource_prefix}-${var.random_string}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
}

resource "azurerm_network_security_group" "this" {
  name                = "security-group"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

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

  security_rule {
    name                       = "allow_ping"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_fio_in"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8765"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_fio_out"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8765"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_resource_group.this
  ]
}

resource "azurerm_subnet" "this" {
  name                 = "${var.resource_prefix}-${var.random_string}-sn"
  resource_group_name  = azurerm_resource_group.this.name
  address_prefixes     = var.address_prefixes
  virtual_network_name = azurerm_virtual_network.this.name

  depends_on = [
    azurerm_resource_group.this,
    azurerm_virtual_network.this
  ]
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id

  depends_on = [
    azurerm_subnet.this,
    azurerm_network_security_group.this
  ]
}

resource "azurerm_public_ip_prefix" "this" {
  name                = "pip-prefix-${var.resource_prefix}-${var.random_string}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  prefix_length       = 30
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "this" {
  name                = "nat-gateway-${var.resource_prefix}-${var.random_string}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "this" {
  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.this.id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = azurerm_subnet.this.id
  nat_gateway_id = azurerm_nat_gateway.this.id

  depends_on = [ azurerm_subnet.this, azurerm_nat_gateway.this ]
}

