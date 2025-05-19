
resource "azurerm_route_table" "route_table" {
  count               = var.firewall != null ? 1 : 0
  name                = "${var.resource_prefix}-rt"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  route {
    name                   = "${var.resource_prefix}-quad0"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.azurerm_firewall.firewall[0].ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "apply_rt" {
  count          = var.firewall != null ? 1 : 0
  subnet_id      = module.vnet.resource.aci_subnet_id
  route_table_id = azurerm_route_table.route_table[0].id
}

