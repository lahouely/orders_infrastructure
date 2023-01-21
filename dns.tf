//namecheap api is unfortunatly too expensive.
//we will have create and edit the DNS A record manually.
/*
resource "namecheap_domain_records" "primary_dns" {
  domain = "youcef.store"
  record {
    hostname = "dev"
    type = "A"
    address = azurerm_public_ip.orders-loadbalancer-public-ip.ip_address
    ttl = 60
  }
  record {
    hostname = "*"
    type = "A"
    address = azurerm_public_ip.orders-loadbalancer-public-ip.ip_address
    ttl = 60
  }
}
*/