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
      name              = "${var.resource_prefix}-aci-subnet"
      address_prefixes  = [var.vnet.address_space]
      service_endpoints = ["Microsoft.Storage"]
      network_security_group = {
        id = module.nsg.resource_id
      }
      route_table = {
        id = var.firewall == null ? null : module.route_table.resource_id
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

