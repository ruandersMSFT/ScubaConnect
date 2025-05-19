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

# VNet which hosts the ScubaGear container
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"

  name                = "${var.resource_prefix}-vnet"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = [var.vnet.address_space]

  subnets = {
    aci-subnet = {
      name                 = "${var.resource_prefix}-aci-subnet"
      address_prefixes     = [var.vnet.address_space]
      service_endpoints    = ["Microsoft.Storage"]
      network_security_group = {
        id = module.nsg.resource_id
      }
      delegation = [
        {
          name = "aci-del"
          service_delegation = {
            name    = "Microsoft.ContainerInstance/containerGroups"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ]
    }
  }
}

