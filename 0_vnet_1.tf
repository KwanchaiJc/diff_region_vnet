resource "azurerm_resource_group" "rg1" {
  name     = var.rgs["rg1"]
  location = var.locations["location1"]
}

resource "azurerm_virtual_network" "vnet1" {
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  name                = var.vnets["vnet1"]
  address_space       = ["10.1.0.0/16"]
  depends_on          = [azurerm_resource_group.rg1]
}

resource "azurerm_subnet" "subnet1" {
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  name                 = var.subnets["subnet1"]
  address_prefixes     = ["10.1.0.0/18"]
  depends_on           = [azurerm_virtual_network.vnet1]
}

resource "azurerm_network_security_group" "sg1" {
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  name                = var.sgs["sg1"]

  security_rule {
    name                       = "allowssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_subnet.subnet1]
}

resource "azurerm_subnet_network_security_group_association" "sg_subnet1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.sg1.id
  depends_on                = [azurerm_subnet.subnet1, azurerm_network_security_group.sg1]
}

resource "azurerm_public_ip" "pubip1" {
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  name                = "vm-pub-ip"
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.rg1, azurerm_virtual_network.vnet1, azurerm_subnet.subnet1]
}

resource "azurerm_network_interface" "nic1" {
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  name                = var.nics["nic1"]
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip1.id
  }

  depends_on = [azurerm_resource_group.rg1, azurerm_subnet.subnet1]
}

resource "azurerm_linux_virtual_machine" "vm1" {
  resource_group_name             = azurerm_resource_group.rg1.name
  location                        = azurerm_resource_group.rg1.location
  name                            = var.vms["vm1"]
  network_interface_ids           = [azurerm_network_interface.nic1.id]
  size                            = var.sizevm
  disable_password_authentication = false
  admin_username                  = var.adminuser
  admin_password                  = var.adminpwd
  os_disk {
    name                 = "os-disk"
    disk_size_gb         = "64"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [azurerm_resource_group.rg1, azurerm_network_interface.nic1]
}