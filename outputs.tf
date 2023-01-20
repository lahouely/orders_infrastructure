output "output-orders-loadbalancer-public-ip" {
  value = azurerm_public_ip.orders-loadbalancer-public-ip.ip_address
}
