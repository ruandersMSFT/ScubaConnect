# Azure Container Instances to run the ScubaGear container
# One group is automatically executed periodically, the other manually
module "container_group" {
  source   = "./modules/azurerm_container_group"
  for_each = toset(["scheduled", "adhoc"])

  name                    = "${local.prefix}-${each.key}-container"
  ip_address_type         = "None"
  location                = module.resource_group.resource.location
  log_analytics_workspace = module.log_analytics_workspace.resource
  os_type                 = "Windows"
  resource_group_name     = module.resource_group.resource.name
  restart_policy          = "Never"

  containers = [
    {
      name   = "${local.prefix}-container"
      image  = var.container_image
      cpu    = "1"
      memory = var.container_memory_gb
      environment_variables = {
        "RUN_TYPE"                         = each.key
        "TENANT_ID"                        = data.azurerm_client_config.current.tenant_id
        "APP_ID"                           = local.app_client_id
        "REPORT_OUTPUT"                    = var.output_storage_container_id == null ? azurerm_storage_container.output[0].id : var.output_storage_container_id
        "TENANT_INPUT"                     = var.input_storage_container_id == null ? azurerm_storage_container.input[0].id : var.input_storage_container_id
        "AZCOPY_ACTIVE_DIRECTORY_ENDPOINT" = local.azure_active_directory_endpoint
        "DEBUG_LOG"                        = "false"
      }
      secure_environment_variables = {
        "PFX_B64" = data.azurerm_key_vault_secret.pfx_b64.value
      }
    }
  ]
}
