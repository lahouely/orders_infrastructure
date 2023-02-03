/*resource "azurerm_resource_group" "orders-storage-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-storage-rg"
}

resource "azurerm_storage_account" "orders-storage-account" {
  name     = "${random_string.orders_storage_account_name.id}orders"
  resource_group_name = azurerm_resource_group.orders-storage-rg.name
  location                 = var.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
  /*network_rules {
    //default_action             = "Deny"
    default_action             = "Allow"
    bypass = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.orders-aks-vnet-default-subnet.id]
  }*/ /*
}
/*
resource "azurerm_storage_share" "orders-storage-sessions-share" {
  name                 = "orders-storage-sessions-share"
  storage_account_name = azurerm_storage_account.orders-storage-account.name
  quota                = 1

  /*acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTo"
    access_policy {
      permissions = "rwdl"
    }
  }*/ /*

  depends_on = [
    azurerm_storage_account.orders-storage-account
  ]
}
*/
