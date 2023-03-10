variable "azure_subscription_id" {}

variable "azure_tenant_id" {}

variable "azure_client_id" {}

variable "azure_client_secret" {}

variable "admin_user" {}

variable "db_password" {}

variable "app_admin_password" {}

variable "admin_public_key_path" {}

variable "cloudflare_api_key" {}

variable "cloudflare_email" {}

variable "cloudflare_zone_id" {}

variable "domain_name_label" {
  description = "a label that will be used to make an FQDN"
}

variable "location" {
  description = "location can be set to centralindia for cost-effectiveness"
}

variable "environment" {
  description = "this variable is used to track the environment: dev, test, prod..."
}

variable "node_count" {
  default = 1
}

variable "cluster_name" {
  default = "orders-k8s"
}

variable "dns_prefix" {
  default = "orders-k8s"
}
