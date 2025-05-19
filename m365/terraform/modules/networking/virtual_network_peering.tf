resource "azurerm_virtual_network_peering" "firewall_peering" {
  count                     = var.firewall != null ? 1 : 0
  name                      = "peer-scuba-to-firewall"
  resource_group_name       = var.resource_group.name
  virtual_network_name      = module.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.firewall_vnet[0].id
}