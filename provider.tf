terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.orders-k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.orders-k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.orders-k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.orders-k8s.kube_config.0.cluster_ca_certificate)
}


//NameCheap api is unfortunatly too expensive.
//We're using their sandbox..
provider "namecheap" {
  user_name   = var.namecheap_user_name
  api_user    = var.namecheap_api_user
  api_key     = var.namecheap_api_key
  use_sandbox = true
}
