resource "azurerm_resource_group" "orders-loadbalancer-vm-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-loadbalancer-vm-rg"
}

resource "azurerm_linux_virtual_machine" "orders-loadbalancer-vm" {
  name                = "${var.location}-${var.environment}-orders-loadbalancer-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-loadbalancer-vm-rg.name
  size                = "Standard_B1s"
  admin_username      = var.admin_user
  custom_data         = base64encode(templatefile("configure_loadbalancer.sh.tftpl", { domain_name_label = var.domain_name_label, location = var.location, orders-webapp-service-lb-ip = kubernetes_service.orders-webapp-service.status.0.load_balancer.0.ingress.0.ip }))

  network_interface_ids = [
    azurerm_network_interface.orders-loadbalancer-vm-public-nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = azurerm_ssh_public_key.admin-public-key.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
