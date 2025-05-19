data "azurerm_public_ip" "firewall_ip" {
  count               = var.firewall != null ? 1 : 0
  name                = var.firewall.pip
  resource_group_name = var.firewall.resource_group
}

data "azurerm_firewall" "firewall" {
  count               = var.firewall != null ? 1 : 0
  name                = var.firewall.name
  resource_group_name = var.firewall.resource_group
}

data "azurerm_virtual_network" "firewall_vnet" {
  count               = var.firewall != null ? 1 : 0
  name                = var.firewall.vnet
  resource_group_name = var.firewall.resource_group
}
