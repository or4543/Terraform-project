#resource-group
resource "azurerm_resource_group" "rg-1" {
  name     = "rg-drugstore-dev-westeu"
  location = var.location
}
#virtual-network
resource "azurerm_virtual_network" "vn-1" {
  name                = "vn-drugstore-dev-westeu"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-1.name
}
#subnet-1
resource "azurerm_subnet" "s-1" {
  name                 = "DBSubnet"
  resource_group_name  = azurerm_resource_group.rg-1.name
  virtual_network_name = azurerm_virtual_network.vn-1.name
  address_prefixes     = ["10.0.1.0/24"]
}
#subnet-2
resource "azurerm_subnet" "s-2" {
  name                 = "WebSubnet"
  resource_group_name  = azurerm_resource_group.rg-1.name
  virtual_network_name = azurerm_virtual_network.vn-1.name
  address_prefixes     = ["10.0.2.0/24"]
}
#nsg-1
resource "azurerm_network_security_group" "nsg-1" {
  name                = "DBNSG-drugstore-dev-westeu"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-1.name

  security_rule {
    name                       = "Allowport22-computer1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "213.57.199.36"
    destination_address_prefix = "*"
    
  }

    security_rule {
    name                       = "Allowport22-computer2"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "79.176.1.92"
    destination_address_prefix = "*"
    
  }
  
  security_rule {
    name                       = "PostgreSQLRule"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
  }
}
resource "azurerm_subnet_network_security_group_association" "asnsga-1" {
  subnet_id                 = azurerm_subnet.s-1.id
  network_security_group_id = azurerm_network_security_group.nsg-1.id
}
#nsg-2
resource "azurerm_network_security_group" "nsg-2" {
  name                = "WebNSG-drugstore-dev-westeu"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-1.name

  security_rule {
    name                       = "Allowport80"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allowport8080"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allowport5000"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allowport22"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_subnet_network_security_group_association" "asnsga-2" {
  subnet_id                 = azurerm_subnet.s-2.id
  network_security_group_id = azurerm_network_security_group.nsg-2.id
}
#vm-1 
resource "azurerm_public_ip" "publicip-1" {
  name                = "DBVM-drugstore-dev-westeu-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-1.name
  allocation_method   = "Static" 
}

resource "azurerm_network_interface" "ani-1" {
  name                = "DBVM-drugstore-dev-westeu"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.s-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.publicip-1.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-1" {
  name                = "DBVM-drugstore-dev-westeu"
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = var.user_name
  admin_password      = var.password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.ani-1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

#vm-2
resource "azurerm_public_ip" "publicip-2" {
  name                = "WebVM-drugstore-dev-westeu-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-1.name
  allocation_method   = "Static" 
}

resource "azurerm_network_interface" "ani-2" {
  name                = "WebVM-drugstore-dev-westeu"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.s-2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.publicip-2.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-2" {
  name                = "WebVM-drugstore-dev-westeu"
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = var.user_name
  admin_password      = var.password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.ani-2.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

