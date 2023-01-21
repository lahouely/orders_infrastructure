output "output-orders-loadbalancer-vm-public-ip" {
  value = azurerm_public_ip.orders-loadbalancer-vm-public-ip.ip_address
}

output "output-orders-loadbalancer-vm-public-fqdn" {
  value = join(".", [azurerm_public_ip.orders-loadbalancer-vm-public-ip.domain_name_label, var.location, "cloudapp.azure.com"])
}

output "to-connect" {
  value = join("@", ["ssh -i ~/.ssh/id_rsa youcef", join(".", [azurerm_public_ip.orders-loadbalancer-vm-public-ip.domain_name_label, var.location, "cloudapp.azure.com"])])
}