resource "azurerm_resource_group" "orders-rg" {
  location = var.location
  name     = join("-",[var.location,var.environment,"orders-rg"])
}

resource "azurerm_public_ip" "orders-loadbalancer-public-ip" {
  name                = join("-",[var.location,var.environment,"orders-loadbalancer-public-ip"])
  resource_group_name = azurerm_resource_group.orders-rg.name
  location            = azurerm_resource_group.orders-rg.location
  allocation_method   = "Static"
}
