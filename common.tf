resource "azurerm_resource_group" "orders-common-rg" {
  location = var.location
  name     = join("-", [var.location, var.environment, "orders-common-rg"])
}

resource "azurerm_ssh_public_key" "admin-public-key" {
  name                = "admin-public-key"
  public_key          = file(var.admin_public_key_path)
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-common-rg.name
}