resource "azurerm_resource_group" "orders-aks-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-aks-rg"
}

resource "azurerm_virtual_network" "orders-aks-vnet" {
  name                = join("-", [var.location, var.environment, "orders-aks-vnet"])
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-aks-rg.name
}

resource "azurerm_subnet" "orders-aks-vnet-subnet01" {
  name                 = join("-", [var.location, var.environment, "orders-aks-vnet-subnet01"])
  virtual_network_name = azurerm_virtual_network.orders-aks-vnet.name
  address_prefixes     = ["10.1.0.0/24"]
  resource_group_name  = azurerm_resource_group.orders-aks-rg.name
}

resource "azurerm_virtual_network_peering" "aks-loadbalancer-peering" {
  name                      = "aks-loadbalancer-peering"
  resource_group_name  = azurerm_resource_group.orders-rg.name
  virtual_network_name      = azurerm_virtual_network.orders-loadbalancer-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.orders-aks-vnet.id
}

resource "azurerm_virtual_network_peering" "loadbalancer-aks-peering" {
  name                      = "loadbalancer-aks-peering"
  resource_group_name  = azurerm_resource_group.orders-aks-rg.name
  virtual_network_name      = azurerm_virtual_network.orders-aks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.orders-loadbalancer-vnet.id
}

resource "azurerm_kubernetes_cluster" "orders-k8s" {
  name       = "${var.location}-${var.environment}-orders-k8s"
  dns_prefix = "orders-k8s"

  location            = var.location
  resource_group_name = azurerm_resource_group.orders-aks-rg.name
  node_resource_group = "${var.location}-${var.environment}-orders-k8s-managed-cluster-rg"
  default_node_pool {
    name       = "nodepool"
    vm_size    = "Standard_B2s"
    node_count = var.node_count
    vnet_subnet_id = azurerm_subnet.orders-aks-vnet-subnet01.id
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
