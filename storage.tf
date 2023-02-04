resource "azurerm_resource_group" "orders-storage-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-storage-rg"
}


resource "azurerm_storage_account" "orders-storage-account" {
  name     = "orders${random_string.orders_storage_account_name.id}"
  resource_group_name = azurerm_resource_group.orders-storage-rg.name
  location                 = var.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
  enable_https_traffic_only = false
  network_rules {
    //default_action             = "Deny"
    default_action             = "Allow"
    bypass = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.orders-aks-vnet-default-subnet.id]
  }
}

resource "azurerm_storage_share" "orders-storage-sessions-share" {
  name                 = "orders-storage-sessions-share"
  storage_account_name = azurerm_storage_account.orders-storage-account.name
  enabled_protocol     = "NFS"
  quota                = 100

  acl {
    id = "MTIzNDU2Nzg5MDEyszQ1zjc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2019-07-02T09:38:21.0000000Z"
      expiry      = "2033-07-02T10:38:21.0000000Z"
    }
  }

  depends_on = [
    azurerm_storage_account.orders-storage-account
  ]
}

/*resource "kubernetes_storage_class" "example" {
  metadata {
    name = "terraform-example"
  }
  storage_provisioner = "file.csi.azure.com"
  reclaim_policy      = "Retain"
  allow_volume_expansion = false
  parameters = {
    type = "pd-standard"
  }
  mount_options = ["file_mode=0700", "dir_mode=0777", "mfsymlinks", "uid=1000", "gid=1000", "nobrl", "cache=none"]
}*/

resource "kubernetes_persistent_volume" "example" {
  metadata {
    name = "example"
  }
  spec {
    storage_class_name = "manual"
    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Delete"
    capacity = {
      storage = "10Gi"
    }
    
    persistent_volume_source {
      nfs {
        server = "10.3.0.4"
        path = "/orders99zz19/orders-storage-sessions-share/"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "example" {
  metadata {
    name = "exampleclaimname"
  }
  spec {
    storage_class_name = "manual"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.example.metadata.0.name}"
  }
}
