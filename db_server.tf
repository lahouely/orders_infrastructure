resource "azurerm_resource_group" "orders-db-rg" {
  location = var.location
  name     = join("-", [var.location, var.environment, "orders-db-rg"])
}

resource "azurerm_mysql_flexible_server" "orders-db-msql-flexible-server" {
  name                   = "orders-db-msql-flexible-server"
  resource_group_name    = azurerm_resource_group.orders-db-rg.name
  location               = var.location
  administrator_login    = var.admin_user
  administrator_password = var.db_password
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.orders-db-vnet-default-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.orders-db-private-dns-zone.id
  sku_name               = "B_Standard_B1ms"
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.orders-db-private-dns-zone-vnet-link]
}