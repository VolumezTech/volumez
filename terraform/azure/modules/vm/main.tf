
resource "azurerm_network_interface" "this" {
  count = var.num_of_vm

  name                          = "nic-${var.vm_type}-${count.index}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "pubConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
  ]
}

resource "azurerm_linux_virtual_machine" "this" {
  count = var.num_of_vm

  name                         = "${var.vm_type}-${count.index}"
  resource_group_name          = var.resource_group_name
  location                     = var.resource_group_location
  zone                         = var.zones[count.index % length(var.zones)]
  size                         = var.vm_size
  proximity_placement_group_id = var.proximity_pg_group_list[count.index % length(var.zones)]
  admin_username               = var.ssh_username
  network_interface_ids = [
    element(azurerm_network_interface.this.*.id, count.index),
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  admin_ssh_key {
    username   = var.ssh_username
    public_key = var.public_key
  }


  depends_on = [
    azurerm_network_interface.this
  ]

  custom_data = base64encode(templatefile("../../../../scripts/deploy_connector.sh", { tenant_token = var.tenant_token, signup_domain = var.signup_domain }))
}