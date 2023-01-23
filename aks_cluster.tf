resource "azurerm_resource_group" "orders-aks-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-aks-rg"
}
/*
resource "azurerm_log_analytics_workspace" "orders-aks-analytics-workspace" {
  # The WorkSpace name has to be unique across the whole of azure;
  # not just the current subscription/tenant.
  name                = "${var.location}-${var.environment}-orders-aks-analytics-workspace"
  sku                 = var.log_analytics_workspace_sku
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-aks-rg.name
}
*/
/*
resource "azurerm_log_analytics_solution" "orders-aks-analytics-ContainerInsights" {
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.orders-aks-analytics-workspace.name
  workspace_resource_id = azurerm_log_analytics_workspace.orders-aks-analytics-workspace.id
  location              = var.location
  resource_group_name   = azurerm_resource_group.orders-aks-rg.name
  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}
*/

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
  }
  linux_profile {
    admin_username = "youcef"
    ssh_key {
      key_data = azurerm_ssh_public_key.youcef-key.public_key
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
