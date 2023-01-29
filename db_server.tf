resource "azurerm_resource_group" "orders-db-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-db-rg"
}

resource "azurerm_mysql_flexible_server" "orders-db-mysql-flexible-server" {
  name                   = "orders-db-mysql-flexible-server"
  resource_group_name    = azurerm_resource_group.orders-db-rg.name
  location               = var.location
  administrator_login    = var.admin_user
  administrator_password = var.db_password
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.orders-db-vnet-default-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.orders-db-private-dns-zone.id
  sku_name               = "B_Standard_B1ms"
  storage{
    auto_grow_enabled = false
    iops = 360
    size_gb = 20
  }
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.orders-db-private-dns-zone-vnet-link]
}

resource "azurerm_mysql_flexible_server_configuration" "orders-db-mysql-flexible-server-no-ssl" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_resource_group.orders-db-rg.name
  server_name         = azurerm_mysql_flexible_server.orders-db-mysql-flexible-server.name
  value               = "OFF"
  depends_on = [
    azurerm_mysql_flexible_server.orders-db-mysql-flexible-server
  ]
}

resource "azurerm_mysql_flexible_database" "orders-db" {
  name                = "orders-db"
  resource_group_name = azurerm_resource_group.orders-db-rg.name
  server_name         = azurerm_mysql_flexible_server.orders-db-mysql-flexible-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
  depends_on = [
    azurerm_mysql_flexible_server.orders-db-mysql-flexible-server
  ]
}

resource "azurerm_linux_virtual_machine" "orders-db-management-vm" {
  name                = "${var.location}-${var.environment}-orders-db-management-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-db-rg.name
  size                = "Standard_B1s"
  admin_username      = var.admin_user
  custom_data         = base64encode(templatefile("deploy_db.sh.tftpl", { domain_name_label = var.domain_name_label, location = var.location, orders-webapp-service-lb-ip = kubernetes_service.orders-webapp-service.status.0.load_balancer.0.ingress.0.ip }))

  network_interface_ids = [
    azurerm_network_interface.orders-management-vm-public-nic.id,
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
  depends_on             = [azurerm_mysql_flexible_database.orders-db]
}