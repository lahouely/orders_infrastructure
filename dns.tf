resource "cloudflare_record" "orders-root-dns-A-record" {
  zone_id         = var.cloudflare_zone_id
  allow_overwrite = true
  proxied         = true
  name            = "@"
  value           = azurerm_public_ip.orders-loadbalancer-vm-public-ip.ip_address
  type            = "A"
  ttl             = 1
}

resource "cloudflare_record" "orders-www-dns-A-record" {
  zone_id         = var.cloudflare_zone_id
  allow_overwrite = true
  proxied         = true
  name            = "www"
  value           = azurerm_public_ip.orders-loadbalancer-vm-public-ip.ip_address
  type            = "A"
  ttl             = 1
}
