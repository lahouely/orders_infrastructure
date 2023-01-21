terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    namecheap = {
      source = "namecheap/namecheap"
      version = ">= 2.0.0"
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

//namecheap api is unfortunatly too expensive.
/*
provider "namecheap" {
  user_name = "user"
  api_user = "user"
  api_key = "key"
}
*/