resource "azurerm_resource_group" "rg2" {
  name     = var.rgs["rg2"]
  location = var.locations["location2"]
}

resource "azurerm_virtual_network" "vnet2" {
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  name                = var.vnets["vnet2"]
  address_space       = ["10.2.0.0/16"]
  depends_on          = [azurerm_resource_group.rg2]
}

resource "azurerm_subnet" "subnet2" {
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  name                 = var.subnets["subnet2"]
  address_prefixes     = ["10.2.0.0/18"]
  depends_on           = [azurerm_virtual_network.vnet2]
}

resource "azurerm_network_security_group" "sg2" {
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  name                = var.sgs["sg2"]

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

  depends_on = [azurerm_subnet.subnet2]
}

resource "azurerm_subnet_network_security_group_association" "sg_subnet2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.sg2.id
  depends_on                = [azurerm_subnet.subnet2, azurerm_network_security_group.sg2]
}

resource "azurerm_network_interface" "nic2" {
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  name                = var.nics["nic2"]
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [azurerm_resource_group.rg2, azurerm_subnet.subnet2]
}

resource "azurerm_linux_virtual_machine" "vm2" {
  resource_group_name             = azurerm_resource_group.rg2.name
  location                        = azurerm_resource_group.rg2.location
  name                            = var.vms["vm2"]
  network_interface_ids           = [azurerm_network_interface.nic2.id]
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

  depends_on = [azurerm_resource_group.rg2, azurerm_network_interface.nic2]
}