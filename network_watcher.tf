/*resource "azurerm_resource_group" "NetworkWatcherRG" {
  location = var.location
  name     = "NetworkWatcherRG"
}

resource "azurerm_network_watcher" "NetworkWatcher" {
  name                = "${var.location}-${var.environment}-NetworkWatcher"
  location            = var.location
  resource_group_name = azurerm_resource_group.NetworkWatcherRG.name
}*/