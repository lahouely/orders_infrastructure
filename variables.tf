variable "subscription_id" {}

variable "tenant_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "location" {
  default     = "centralindia"
  description = "location set to centralindia for cost-effectiveness"
}

variable "environment" {
  default     = "dev"
  description = "this variable is used to track environment: dev or prod"
}
