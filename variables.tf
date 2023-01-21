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
  description = "this variable is used to track environment: dev or prod"
}
