resource "azurerm_resource_group" "orders-network-rg" {
  location = var.location
  name     = "${var.location}-${var.environment}-orders-network-rg"
}

resource "azurerm_virtual_network" "orders-loadbalancer-vnet" {
  name                = "${var.location}-${var.environment}-orders-loadbalancer-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}

resource "azurerm_virtual_network" "orders-aks-vnet" {
  name                = "${var.location}-${var.environment}-orders-aks-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}

resource "azurerm_virtual_network" "orders-db-vnet" {
  name                = "${var.location}-${var.environment}-orders-db-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}

resource "azurerm_virtual_network" "orders-storage-vnet" {
  name                = "${var.location}-${var.environment}-orders-storage-vnet"
  address_space       = ["10.3.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}

resource "azurerm_virtual_network_peering" "aks-loadbalancer-peering" {
  name                      = "aks-loadbalancer-peering"
  resource_group_name       = azurerm_resource_group.orders-network-rg.name
  virtual_network_name      = azurerm_virtual_network.orders-loadbalancer-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.orders-aks-vnet.id
  depends_on = [
    azurerm_virtual_network.orders-loadbalancer-vnet,
    azurerm_virtual_network.orders-aks-vnet
  ]
}

resource "azurerm_virtual_network_peering" "loadbalancer-aks-peering" {
  name                      = "loadbalancer-aks-peering"
  resource_group_name       = azurerm_resource_group.orders-network-rg.name
  virtual_network_name      = azurerm_virtual_network.orders-aks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.orders-loadbalancer-vnet.id
  depends_on = [
    azurerm_virtual_network.orders-loadbalancer-vnet,
    azurerm_virtual_network.orders-aks-vnet
  ]
}

resource "azurerm_virtual_network_peering" "aks-db-peering" {
  name                      = "aks-db-peering"
  resource_group_name       = azurerm_resource_group.orders-network-rg.name
  virtual_network_name      = azurerm_virtual_network.orders-db-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.orders-aks-vnet.id
  depends_on = [
    azurerm_virtual_network.orders-aks-vnet,
    azurerm_virtual_network.orders-db-vnet
  ]
}

resource "azurerm_virtual_network_peering" "db-aks-peering" {
  name                      = "db-aks-peering"
  resource_group_name       = azurerm_resource_group.orders-network-rg.name
  virtual_network_name      = azurerm_virtual_network.orders-aks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.orders-db-vnet.id
  depends_on = [
    azurerm_virtual_network.orders-aks-vnet,
    azurerm_virtual_network.orders-db-vnet
  ]
}

resource "azurerm_virtual_network_peering" "aks-storage-peering" {
  name                      = "aks-storage-peering"
  resource_group_name       = azurerm_resource_group.orders-network-rg.name
  virtual_network_name      = azurerm_virtual_network.orders-storage-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.orders-aks-vnet.id
  depends_on = [
    azurerm_virtual_network.orders-storage-vnet,
    azurerm_virtual_network.orders-aks-vnet
  ]
}

resource "azurerm_virtual_network_peering" "storage-aks-peering" {
  name                      = "storage-aks-peering"
  resource_group_name       = azurerm_resource_group.orders-network-rg.name
  virtual_network_name      = azurerm_virtual_network.orders-aks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.orders-storage-vnet.id
  depends_on = [
    azurerm_virtual_network.orders-storage-vnet,
    azurerm_virtual_network.orders-aks-vnet
  ]
}

resource "azurerm_subnet" "orders-loadbalancer-vnet-default-subnet" {
  name                 = "${var.location}-${var.environment}-orders-loadbalancer-vnet-default-subnet"
  virtual_network_name = azurerm_virtual_network.orders-loadbalancer-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_virtual_network.orders-loadbalancer-vnet
  ]
}

resource "azurerm_subnet" "orders-aks-vnet-default-subnet" {
  name                 = "${var.location}-${var.environment}-orders-aks-vnet-default-subnet"
  virtual_network_name = azurerm_virtual_network.orders-aks-vnet.name
  address_prefixes     = ["10.1.0.0/24"]
  resource_group_name  = azurerm_resource_group.orders-network-rg.name
  service_endpoints    = ["Microsoft.Storage"]
  depends_on = [
    azurerm_virtual_network.orders-aks-vnet
  ]
}

resource "azurerm_subnet" "orders-db-vnet-default-subnet" {
  name                 = "${var.location}-${var.environment}-orders-db-vnet-default-subnet"
  virtual_network_name = azurerm_virtual_network.orders-db-vnet.name
  address_prefixes     = ["10.2.0.0/24"]
  resource_group_name  = azurerm_resource_group.orders-network-rg.name

  service_endpoints = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
  depends_on = [
    azurerm_virtual_network.orders-db-vnet
  ]
}

resource "azurerm_subnet" "orders-db-vnet-management-subnet" {
  name                 = "${var.location}-${var.environment}-orders-db-vnet-management-subnet"
  virtual_network_name = azurerm_virtual_network.orders-db-vnet.name
  address_prefixes     = ["10.2.1.0/24"]
  resource_group_name  = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_virtual_network.orders-loadbalancer-vnet
  ]
}

resource "azurerm_subnet" "orders-storage-vnet-default-subnet" {
  name                                      = "${var.location}-${var.environment}-orders-storage-vnet-default-subnet"
  virtual_network_name                      = azurerm_virtual_network.orders-storage-vnet.name
  address_prefixes                          = ["10.3.0.0/24"]
  resource_group_name                       = azurerm_resource_group.orders-network-rg.name
  service_endpoints                         = ["Microsoft.Storage"]
  private_endpoint_network_policies_enabled = true
  depends_on = [
    azurerm_virtual_network.orders-storage-vnet
  ]
}


variable "orders-public-nsg-ports" {
  default = [
    { "name" = "SSH", "port" = 22, "priority" = 100 },
    { "name" = "HTTP", "port" = 80, "priority" = 101 },
    { "name" = "HTTPS", "port" = 443, "priority" = 102 }
  ]
}

resource "azurerm_network_security_group" "orders-public-nsg" {
  name                = "${var.location}-${var.environment}-orders-public-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name

  dynamic "security_rule" {
    iterator = item
    for_each = var.orders-public-nsg-ports
    content {
      name                       = item.value.name
      priority                   = item.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = item.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}

resource "azurerm_public_ip" "orders-loadbalancer-vm-public-ip" {
  name                = "${var.location}-${var.environment}-orders-loadbalancer-vm-public-ip"
  allocation_method   = "Static"
  domain_name_label   = var.domain_name_label
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}

resource "azurerm_network_interface" "orders-loadbalancer-vm-public-nic" {
  name                = "${var.location}-${var.environment}-orders-loadbalancer-vm-public-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.orders-loadbalancer-vnet-default-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.orders-loadbalancer-vm-public-ip.id
  }
  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}

resource "azurerm_network_interface_security_group_association" "orders-public-nsg-lb-nic-association" {
  network_interface_id      = azurerm_network_interface.orders-loadbalancer-vm-public-nic.id
  network_security_group_id = azurerm_network_security_group.orders-public-nsg.id
  depends_on = [
    azurerm_network_interface.orders-loadbalancer-vm-public-nic,
    azurerm_network_security_group.orders-public-nsg
  ]
}

resource "azurerm_public_ip" "orders-management-vm-public-ip" {
  name                = "${var.location}-${var.environment}-orders-db-management-vm-public-ip"
  allocation_method   = "Static"
  domain_name_label   = "${var.domain_name_label}-db"
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}


resource "azurerm_network_interface" "orders-management-vm-public-nic" {
  name                = "${var.location}-${var.environment}-orders-management-vm-public-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.orders-db-vnet-management-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.orders-management-vm-public-ip.id
  }
  depends_on = [
    azurerm_subnet.orders-db-vnet-management-subnet,
    azurerm_public_ip.orders-management-vm-public-ip
  ]
}

resource "azurerm_network_interface_security_group_association" "orders-public-nsg-management-vm-nic-association" {
  network_interface_id      = azurerm_network_interface.orders-management-vm-public-nic.id
  network_security_group_id = azurerm_network_security_group.orders-public-nsg.id
  depends_on = [
    azurerm_network_interface.orders-management-vm-public-nic,
    azurerm_network_security_group.orders-public-nsg
  ]
}

resource "azurerm_private_dns_zone" "orders-db-private-dns-zone" {
  name                = "orders-db-private-dns-zone.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_resource_group.orders-network-rg
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "orders-db-private-dns-zone-vnet-link" {
  name                  = "orders-db-private-dns-zone-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.orders-db-private-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.orders-db-vnet.id
  resource_group_name   = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_private_dns_zone.orders-db-private-dns-zone,
    azurerm_virtual_network.orders-db-vnet
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "orders-aks-private-dns-zone-vnet-link" {
  name                  = "orders-aks-private-dns-zone-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.orders-db-private-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.orders-aks-vnet.id
  resource_group_name   = azurerm_resource_group.orders-network-rg.name
  depends_on = [
    azurerm_private_dns_zone.orders-db-private-dns-zone,
    azurerm_virtual_network.orders-aks-vnet
  ]
}

resource "azurerm_private_endpoint" "orders-nfs-storage-private-endpoint" {
  name                = "${var.location}-${var.environment}-orders-nfs-storage-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-network-rg.name
  subnet_id           = azurerm_subnet.orders-storage-vnet-default-subnet.id

  custom_network_interface_name = "${var.location}-${var.environment}-orders-nfs-storage-private-endpoint-nic"
  private_service_connection {
    name                           = "${var.location}-${var.environment}-orders-nfs-storage-private-endpoint-private-service-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.orders-storage-account.id
    subresource_names              = ["file"]
  }

}