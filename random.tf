resource "random_string" "orders_storage_account_name" {
  length  = 6
  upper   = false
  special = false
}

resource "random_string" "orders_db_password" {
  length  = 20
  special = true
}

resource "random_string" "orders_app_admin_password" {
  length  = 20
  special = true
}