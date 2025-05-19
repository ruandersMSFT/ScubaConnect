# Azure Resource Group that contains most resources
module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  enable_telemetry = false
  name             = "${var.resource_group_name}-${var.serial_number}"
  location         = var.location
}


module "networking" {
  count           = var.vnet == null ? 0 : 1
  source          = "./modules/networking"
  resource_group  = module.resource_group.resource
  resource_prefix = local.prefix
  firewall        = var.firewall
  vnet            = var.vnet
}
