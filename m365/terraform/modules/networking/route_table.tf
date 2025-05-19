module "route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"
  count   = var.firewall != null ? 1 : 0

  name                = "${var.resource_prefix}-rt"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  routes = {
    AllowInbound = {
      name                   = "${var.resource_prefix}-quad0"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.azurerm_firewall.firewall[0].ip_configuration[0].private_ip_address
    }
  }
}
