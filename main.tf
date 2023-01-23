resource "azurerm_resource_group" "NetworkWatcherRG" {
  location = var.location
  name     = "NetworkWatcherRG"
}

resource "azurerm_network_watcher" "NetworkWatcher" {
  name                = join("-", [var.location, var.environment, "NetworkWatcher"])
  location            = var.location
  resource_group_name = azurerm_resource_group.NetworkWatcherRG.name
}

resource "azurerm_resource_group" "orders-rg" {
  location = var.location
  name     = join("-", [var.location, var.environment, "orders-rg"])
}

resource "azurerm_ssh_public_key" "admin-public-key" {
  name                = "admin-public-key"
  public_key          = file(var.admin_public_key_path)
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-rg.name
}

resource "azurerm_virtual_network" "orders-loadbalancer-vnet" {
  name                = join("-", [var.location, var.environment, "orders-loadbalancer-vnet"])
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-rg.name
}

resource "azurerm_subnet" "orders-loadbalancer-vnet-subnet01" {
  name                 = join("-", [var.location, var.environment, "orders-loadbalancer-vnet-subnet01"])
  virtual_network_name = azurerm_virtual_network.orders-loadbalancer-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = azurerm_resource_group.orders-rg.name
}

resource "azurerm_network_security_group" "orders-nsg01" {
  name                = join("-", [var.location, var.environment, "orders-nsg01"])
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "orders-loadbalancer-vm-public-ip" {
  name                = join("-", [var.location, var.environment, "orders-loadbalancer-vm-public-ip"])
  allocation_method   = "Static"
  domain_name_label   = var.domain_name_label
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-rg.name
}

resource "azurerm_network_interface" "orders-loadbalancer-vm-public-nic" {
  name                = join("-", [var.location, var.environment, "orders-loadbalancer-vm-public-nic"])
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.orders-loadbalancer-vnet-subnet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.orders-loadbalancer-vm-public-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsgA1" {
  network_interface_id      = azurerm_network_interface.orders-loadbalancer-vm-public-nic.id
  network_security_group_id = azurerm_network_security_group.orders-nsg01.id
}

resource "azurerm_linux_virtual_machine" "orders-loadbalancer-vm" {
  name                = join("-", [var.location, var.environment, "orders-loadbalancer-vm"])
  location            = var.location
  resource_group_name = azurerm_resource_group.orders-rg.name
  size                = "Standard_B1s"
  admin_username      = var.admin_user
  custom_data         = filebase64("configure_loadbalancer.sh")
  custom_data         = base64encode(templatefile("configure_loadbalancer.sh.tftpl",{ domain_name_label = var.domain_name_label, location = var.location, orders-webapp-service-lb-ip = kubernetes_service.orders-webapp-service.status.0.load_balancer.0.ingress.0.ip }))

  network_interface_ids = [
    azurerm_network_interface.orders-loadbalancer-vm-public-nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = azurerm_ssh_public_key.admin-public-key.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
