data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}

locals {
  name                            = var.prefix_override != null ? var.prefix_override : replace(lower(var.app_name), " ", "-")
  azure_active_directory_endpoint = var.environment == "public" ? "https://login.microsoftonline.com" : var.environment == "usgovernment" ? "https://login.microsoftonline.us" : null
  azure_environment               = var.environment == "public" ? "AzureCloud" : var.environment == "usgovernment" ? "AzureUSGovernment" : null
  azure_portal_endpoint           = var.environment == "public" ? "https://portal.azure.com" : var.environment == "usgovernment" ? "https://portal.azure.us" : null
}

# Azure Resource Group that contains most resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${var.serial_number}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "monitor_law" {
  name                = "${local.name}-monitor-loganalytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 90

  lifecycle {
    ignore_changes = [tags]
  }
}

# Creates the app registration, or reads an existing one, which is used by the ScubaGear container
module "app" {
  source                           = "./modules/app"
  resource_group                   = azurerm_resource_group.rg
  resource_prefix                  = local.name
  app_name                         = var.app_name
  azure_portal_endpoint            = local.azure_portal_endpoint
  image_path                       = var.image_path
  create_app                       = var.create_app
  contact_emails                   = var.contact_emails
  allowed_access_ips               = try(var.vnet.allowed_access_ip_list, null)
  certificate_rotation_period_days = var.certificate_rotation_period_days
  app_multi_tenant                 = var.app_multi_tenant
  is_us_gov                        = var.environment == "usgovernment" ? true : false
  tenant_id                        = data.azurerm_client_config.current.tenant_id
  object_id                        = data.azuread_client_config.current.object_id
}

module "networking" {
  count           = var.vnet == null ? 0 : 1
  source          = "./modules/networking"
  resource_group  = azurerm_resource_group.rg
  resource_prefix = local.name
  firewall        = var.firewall
  vnet            = var.vnet
}

module "container" {
  source                          = "./modules/container"
  resource_prefix                 = local.name
  resource_group                  = azurerm_resource_group.rg
  azure_active_directory_endpoint = local.azure_active_directory_endpoint
  azure_environment               = local.azure_environment
  container_registry              = var.container_registry
  container_image                 = var.container_image
  application_client_id           = module.app.client_id
  application_object_id           = module.app.sp_object_id
  application_pfx_b64             = module.app.certificate_pfx_b64
  allowed_access_ips              = try(var.vnet.allowed_access_ip_list, null)
  subnet_ids                      = var.vnet == null ? null : [module.networking[0].aci_subnet_id]
  schedule_interval               = var.schedule_interval
  output_storage_container_id     = var.output_storage_container_id
  input_storage_container_id      = var.input_storage_container_id
  contact_emails                  = var.contact_emails
  log_analytics_workspace         = azurerm_log_analytics_workspace.monitor_law
  container_memory_gb             = var.container_memory_gb
  tenant_id                       = data.azurerm_client_config.current.tenant_id
}
