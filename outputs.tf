output "output-orders-loadbalancer-vm-public-ip" {
  value = azurerm_public_ip.orders-loadbalancer-vm-public-ip.ip_address
}

output "output-orders-loadbalancer-vm-public-fqdn" {
  value = "${azurerm_public_ip.orders-loadbalancer-vm-public-ip.domain_name_label}.${var.location}.cloudapp.azure.com"
}

output "to-connect-to-the-loadbalancer-vm-via-ssh" {
  value = "ssh -i ${replace(var.admin_public_key_path, "/[.]pub$/", "")} ${var.admin_user}@${azurerm_public_ip.orders-loadbalancer-vm-public-ip.domain_name_label}.${var.location}.cloudapp.azure.com"
}

output "to-connect-to-the-db-management-vm-via-ssh" {
  value = "ssh -i ${replace(var.admin_public_key_path, "/[.]pub$/", "")} ${var.admin_user}@${azurerm_public_ip.orders-management-vm-public-ip.domain_name_label}.${var.location}.cloudapp.azure.com"
}

output "orders_app_admin_password" {
  value = random_string.orders_app_admin_password.result
}

output "orders_db_password" {
  value = random_string.orders_db_password.result
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.orders-k8s.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.orders-k8s.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.orders-k8s.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.orders-k8s.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.orders-k8s.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.orders-k8s.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.orders-k8s.kube_config_raw
  sensitive = true
}

output "orders-webapp-service-lb-ip" {
  value = kubernetes_service.orders-webapp-service.status.0.load_balancer.0.ingress.0.ip
}

output "nfs-endpoint-private-ip" {
  value = azurerm_private_endpoint.orders-nfs-storage-private-endpoint.private_service_connection.0.private_ip_address
}
