variable "azure_subscription_id" {}

variable "azure_tenant_id" {}

variable "azure_client_id" {}

variable "azure_client_secret" {}

variable "namecheap_user_name" {}

variable "namecheap_api_user" {}

variable "namecheap_api_key" {}

variable "admin_user" {
  default = "youcef"
}

variable "admin_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "domain_name_label" {
  default = "youcefstoring"
}

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

variable "cluster_name" {
  default = "orders-k8s"
}

variable "dns_prefix" {
  default = "orders-k8s"
}
