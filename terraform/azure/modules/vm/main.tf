
resource "azurerm_public_ip" "this" {
  count = var.num_of_vm

  sku                 = "Standard"
  name                = "${var.vm_type}-publicIP-${count.index}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  zones               = [var.zones[count.index % length(var.zones)]]
  allocation_method   = "Static"
}

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
    public_ip_address_id          = azurerm_public_ip.this["${count.index % var.num_of_vm}"].id
  }

  depends_on = [
    azurerm_public_ip.this
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
    azurerm_public_ip.this,
    azurerm_network_interface.this
  ]
}

  resource "null_resource" "node_config" {
  count = var.num_of_vm

  connection {
    type        = "ssh"
    user        = var.ssh_username
    private_key = var.private_key
    host        = azurerm_public_ip.this[count.index].ip_address
    agent       = false
  }

  provisioner "file" {
    source      = "../../../../scripts/deploy_connector.sh"
    destination = "/tmp/deploy_connector.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p -m 0777 /var/log/volumez",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${azurerm_public_ip.this[count.index].ip_address}"
      ]
  }

 provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/deploy_connector.sh",
      "sudo /tmp/deploy_connector.sh ${var.tenant_token} ${var.signup_domain}"
    ]
  }

  depends_on = [
    azurerm_linux_virtual_machine.this, 
  ]
}
