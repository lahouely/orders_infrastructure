resource "azurerm_resource_group" "NetworkWatcherRG" {
  location = var.location
  name     = "NetworkWatcherRG"
}

resource "azurerm_resource_group" "orders-loadbalancer-public-ip-rg" {
  location = var.location
  name     = join("-", [var.location, var.environment, "orders-loadbalancer-public-ip-rg"])
}

resource "azurerm_public_ip" "orders-loadbalancer-public-ip" {
  name                = join("-", [var.location, var.environment, "orders-loadbalancer-public-ip"])
  resource_group_name = azurerm_resource_group.orders-loadbalancer-public-ip-rg.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_resource_group" "orders-loadbalancer-vm-rg" {
  location = var.location
  name     = join("-", [var.location, var.environment, "orders-loadbalancer-vm-rg"])
}

resource "azurerm_resource_group" "youcef-key-rg" {
  location = var.location
  name     = join("-", [var.location, var.environment, "youcef-key-rg"])
}

resource "azurerm_ssh_public_key" "youcef-key" {
  name                = "youcef-key"
  resource_group_name = azurerm_resource_group.youcef-key-rg.name
  location            = var.location
  public_key          = file("~/.ssh/id_rsa.pub")
}