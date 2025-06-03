resource "azurerm_virtual_network_peering" "peer1" {
  name                         = var.peers["peer1"]
  resource_group_name          = azurerm_resource_group.rg1.name
  virtual_network_name         = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
  depends_on                   = [azurerm_resource_group.rg1, azurerm_resource_group.rg2, azurerm_virtual_network.vnet1, azurerm_virtual_network.vnet2]
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                         = var.peers["peer2"]
  resource_group_name          = azurerm_resource_group.rg2.name
  virtual_network_name         = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet1.id
  allow_virtual_network_access = true
  depends_on                   = [azurerm_resource_group.rg1, azurerm_resource_group.rg2, azurerm_virtual_network.vnet1, azurerm_virtual_network.vnet2]
}