resource "azurerm_resource_group" "orders-rg" {
  location = var.location
  name     = join("-",[var.location,environment,"orders-rg"]
}
