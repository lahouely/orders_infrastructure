variable "azure_subscription_id" {}

variable "azure_tenant_id" {}

variable "azure_client_id" {}

variable "azure_client_secret" {}

variable "namecheap_user_name" {}

variable "namecheap_api_user" {}

variable "namecheap_api_key" {}

variable "location" {
  default     = "centralindia"
  description = "location set to centralindia for cost-effectiveness"
}

variable "environment" {
  default     = "dev"
  description = "this variable is used to track the environment: dev, test, prod..."
}

variable "node_count" {
  default = 1
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "aks_service_principal_app_id" {
  default = ""
}

variable "aks_service_principal_client_secret" {
  default = ""
}

variable "cluster_name" {
  default = "orders-k8s"
}

variable "dns_prefix" {
  default = "orders-k8s"
}

# Refer to https://azure.microsoft.com/global-infrastructure/services/?products=monitor for available Log Analytics regions.


variable "log_analytics_workspace_name" {
  default = "orders-LogAnalyticsWorkspaceName"
}

# Refer to https://azure.microsoft.com/pricing/details/monitor/ for Log Analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}