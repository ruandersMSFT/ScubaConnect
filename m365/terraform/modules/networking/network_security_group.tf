# Network Security Group used by the VNet, allowing only 443 outbound
# Further destination restrictions may be imposed by Azure Firewall
module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  name                = "${var.resource_prefix}-nsg"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  security_rules = {
    AllowInbound = {
      name                       = "Allow-Inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [80, 443]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    DenyOutbound = {
      name                       = "Deny-Inbound"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
