resource "azurerm_virtual_network" "example" {
  name                = "vn-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.network_range]
  dns_servers         = [cidrhost(cidrsubnet(var.network_range, var.number_of_subnets, 0), 4), "168.63.129.16"]
}

resource "azurerm_subnet" "example" {
  count                = var.number_of_subnets
  name                 = "subnet-${count.index}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [cidrsubnet(var.network_range, var.number_of_subnets, count.index)]
}

resource "azurerm_network_security_group" "example" {
  count               = var.number_of_subnets
  name                = "nsg-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowRDPInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  count                     = var.number_of_subnets
  subnet_id                 = azurerm_subnet.example[count.index].id
  network_security_group_id = azurerm_network_security_group.example[count.index].id
}


resource "azurerm_virtual_network" "example01" {
  name                = "peer-vn-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.network_range]
  dns_servers         = [cidrhost(cidrsubnet(var.peer_network_range, var.number_of_subnets, 0), 4), "168.63.129.16"]
}

resource "azurerm_subnet" "example01" {
  count                = var.number_of_subnets
  name                 = "peer-subnet-${count.index}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example01.name
  address_prefixes     = [cidrsubnet(var.peer_network_range, var.number_of_subnets, count.index)]
}

resource "azurerm_network_security_group" "example01" {
  count               = var.number_of_subnets
  name                = "peer-nsg-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowRDPInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example01" {
  count                     = var.number_of_subnets
  subnet_id                 = azurerm_subnet.example01[count.index].id
  network_security_group_id = azurerm_network_security_group.example01[count.index].id
}

resource "azurerm_virtual_network_peering" "example" {
  name                         = "peer-${azurerm_virtual_network.example.name}-to-${azurerm_virtual_network.example01.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.example.name
  remote_virtual_network_id    = azurerm_virtual_network.example01.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "example01" {
  name                         = "peer-${azurerm_virtual_network.example01.name}-to-${azurerm_virtual_network.example.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.example01.name
  remote_virtual_network_id    = azurerm_virtual_network.example.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}