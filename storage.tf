resource "azurerm_resource_group" "orders-storage-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-storage-rg"
}


resource "azurerm_storage_account" "orders-storage-account" {
  name                      = "orders${random_string.orders_storage_account_name.id}"
  resource_group_name       = azurerm_resource_group.orders-storage-rg.name
  location                  = var.location
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  account_kind              = "FileStorage"
  enable_https_traffic_only = false
  network_rules {
    //default_action             = "Deny"
    default_action             = "Allow"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.orders-aks-vnet-default-subnet.id]
  }
  depends_on = [
    azurerm_resource_group.orders-storage-rg
  ]
}

resource "azurerm_storage_share" "orders-storage-nfs-share-sessions" {
  name                 = "orders-storage-nfs-share-sessions"
  storage_account_name = azurerm_storage_account.orders-storage-account.name
  enabled_protocol     = "NFS"
  quota                = 100

  /*acl {
    id = "MTIzNDU2Nzg5MDEyszQ1zjc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2019-07-02T09:38:21.0000000Z"
      expiry      = "2033-07-02T10:38:21.0000000Z"
    }
  }*/

  depends_on = [
    azurerm_storage_account.orders-storage-account
  ]
}

resource "azurerm_storage_share" "orders-storage-nfs-share-resumes" {
  name                 = "orders-storage-nfs-share-resumes"
  storage_account_name = azurerm_storage_account.orders-storage-account.name
  enabled_protocol     = "NFS"
  quota                = 100

  /*acl {
    id = "MTIzNDU2Nzg5MDEyszQ1zjc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2019-07-02T09:38:21.0000000Z"
      expiry      = "2033-07-02T10:38:21.0000000Z"
    }
  }*/

  depends_on = [
    azurerm_storage_account.orders-storage-account
  ]
}


resource "kubernetes_persistent_volume" "orders-nfs-pv-sessions" {
  metadata {
    name = "orders-nfs-pv-sessions"
  }
  spec {
    storage_class_name               = "manual"
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Delete"
    capacity = {
      storage = "10Gi"
    }

    persistent_volume_source {
      nfs {
        server = azurerm_private_endpoint.orders-nfs-storage-private-endpoint.private_service_connection.0.private_ip_address
        path   = "/${azurerm_storage_account.orders-storage-account.name}/${azurerm_storage_share.orders-storage-nfs-share-sessions.name}/"
      }
    }
  }
  depends_on = [
    azurerm_storage_share.orders-storage-nfs-share-sessions
  ]
}

resource "kubernetes_persistent_volume" "orders-nfs-pv-resumes" {
  metadata {
    name = "orders-nfs-pv-resumes"
  }
  spec {
    storage_class_name               = "manual"
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Delete"
    capacity = {
      storage = "10Gi"
    }

    persistent_volume_source {
      nfs {
        server = azurerm_private_endpoint.orders-nfs-storage-private-endpoint.private_service_connection.0.private_ip_address
        path   = "/${azurerm_storage_account.orders-storage-account.name}/${azurerm_storage_share.orders-storage-nfs-share-resumes.name}/"
      }
    }
  }
  depends_on = [
    azurerm_storage_share.orders-storage-nfs-share-resumes
  ]
}

resource "kubernetes_persistent_volume_claim" "orders-nfs-pvc-sessions" {
  metadata {
    name = "orders-nfs-pvc-sessions"
  }
  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.orders-nfs-pv-sessions.metadata.0.name
  }
  depends_on = [
    kubernetes_persistent_volume.orders-nfs-pv-sessions
  ]
}


resource "kubernetes_persistent_volume_claim" "orders-nfs-pvc-resumes" {
  metadata {
    name = "orders-nfs-pvc-resumes"
  }
  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.orders-nfs-pv-resumes.metadata.0.name
  }
  depends_on = [
    kubernetes_persistent_volume.orders-nfs-pv-resumes
  ]
}

