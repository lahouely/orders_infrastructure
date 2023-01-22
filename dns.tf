//namecheap api is unfortunatly too expensive.
//We're using their sandbox.
//In the real world we will have create and edit the DNS A records manually.
//tested and validated, but currently disabled for deployment speed.

resource "namecheap_domain_records" "primary_dns" {
  domain = "youcef.store"
  record {
    hostname = "dev"
    type     = "A"
    address  = azurerm_public_ip.orders-loadbalancer-vm-public-ip.ip_address
    ttl      = 60
  }
  record {
    hostname = "*"
    type     = "A"
    address  = azurerm_public_ip.orders-loadbalancer-vm-public-ip.ip_address
    ttl      = 60
  }
}

