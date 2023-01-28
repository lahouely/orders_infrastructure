resource "azurerm_resource_group" "orders-aks-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-aks-rg"
}

resource "azurerm_kubernetes_cluster" "orders-k8s" {
  name       = "${var.location}-${var.environment}-orders-k8s"
  dns_prefix = "orders-k8s"

  location            = var.location
  resource_group_name = azurerm_resource_group.orders-aks-rg.name
  node_resource_group = "${var.location}-${var.environment}-orders-k8s-managed-cluster-rg"
  default_node_pool {
    name           = "nodepool"
    vm_size        = "Standard_B2s"
    node_count     = var.node_count
    vnet_subnet_id = azurerm_subnet.orders-aks-vnet-default-subnet.id
  }
  linux_profile {
    admin_username = var.admin_user
    ssh_key {
      key_data = azurerm_ssh_public_key.admin-public-key.public_key
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  service_principal {
    client_id     = var.azure_client_id
    client_secret = var.azure_client_secret
  }
}
