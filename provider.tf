terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.41.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.33.1"
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
  host                   = azurerm_kubernetes_cluster.orders-k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.orders-k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.orders-k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.orders-k8s.kube_config.0.cluster_ca_certificate)
}

provider "cloudflare" {
  api_key = var.cloudflare_api_key
  email   = var.cloudflare_email
}