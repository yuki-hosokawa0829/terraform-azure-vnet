resource "azurerm_virtual_network" "example" {
  name                = "vn-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [local.network_range]
  dns_servers         = [cidrhost(cidrsubnet(local.network_range, local.number_of_subnets, 0), 4), "168.63.129.15"]
}

resource "azurerm_subnet" "example" {
  count                = local.number_of_subnets
  name                 = "subnet-${count.index}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [cidrsubnet(local.network_range, local.number_of_subnets, count.index)]
}

resource "azurerm_network_security_group" "example" {
  count               = local.number_of_subnets
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
  count                     = local.number_of_subnets
  subnet_id                 = azurerm_subnet.example[count.index].id
  network_security_group_id = azurerm_network_security_group.example[count.index].id
}