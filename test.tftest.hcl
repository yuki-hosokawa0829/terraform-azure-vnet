variables {
  prefix              = "prefix"
  resource_group_name = "rg-name"
  location            = "japanwest"
  network_range       = "192.168.0.0/24"
  number_of_subnets   = 3
}

provider "azurerm" {
  features {}
}

run "check_virtual_network_name" {
  command = plan

  assert {
    condition     = startswith(azurerm_virtual_network.example.name, "vn-")
    error_message = "Virtual Network name should begin with vn-."
  }
}

run "check_subnet_name" {
  command = plan

  assert {
    condition     = startswith(azurerm_subnet.example[var.number_of_subnets - 1].name, "subnet-")
    error_message = "Virtual Network name should begin with subnet-."
  }
}

run "check_virtual_network_location" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.example.location == "japanwest"
    error_message = "Resource should be deployed at japanwest region."
  }
}

run "check_virtual_network_address_range" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.example.address_space[0] == var.network_range
    error_message = "Virtual Network range should be ${var.network_range}."
  }
}

run "check_virtual_network_dns_server_address_1" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.example.dns_servers[0] == cidrhost(cidrsubnet(var.network_range, var.number_of_subnets, 0), 4)
    error_message = "IP address of DNS server should be ${cidrhost(cidrsubnet(var.network_range, var.number_of_subnets, 0), 4)}"
  }
}

run "check_virtual_network_dns_server_address_2" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.example.dns_servers[1] == "168.63.129.16" && length(azurerm_virtual_network.example.dns_servers.*) == 2
    error_message = "IP address of DNS server should contain 168.63.129.16"
  }
}

run "check_subnet_address_range" {
  command = plan

  assert {
    condition     = azurerm_subnet.example[var.number_of_subnets - 1].address_prefixes[0] == cidrsubnet(var.network_range, var.number_of_subnets, var.number_of_subnets - 1)
    error_message = "Subnet range should between ${cidrsubnet(var.network_range, var.number_of_subnets, 0)} and ${cidrsubnet(var.network_range, var.number_of_subnets, var.number_of_subnets - 1)}"
  }
}

run "check_number_of_subnet" {
  command = plan

  assert {
    condition     = length(azurerm_subnet.example.*) == var.number_of_subnets
    error_message = "Number of subnets should be ${var.number_of_subnets}"
  }
}