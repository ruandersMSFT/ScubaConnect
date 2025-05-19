# Azure Container Instances to run the ScubaGear container
# One group is automatically executed periodically, the other manually
module "container_group" {
  source   = "../azurerm_container_group"
  for_each = toset(["scheduled", "adhoc"])

  name                = "${var.resource_prefix}-${each.key}-container"
  ip_address_type     = "None"
  location            = var.resource_group.location
  os_type             = "Windows"
  resource_group_name = var.resource_group.name
  restart_policy      = "Never"

  containers = [
    {
      name   = "${var.resource_prefix}-container"
      image  = var.container_image
      cpu    = "1"
      memory = var.container_memory_gb
      environment_variables = {
        "RUN_TYPE"                         = each.key
        "TENANT_ID"                        = var.tenant_id
        "APP_ID"                           = var.application_client_id
        "REPORT_OUTPUT"                    = var.output_storage_container_id == null ? azurerm_storage_container.output[0].id : var.output_storage_container_id
        "TENANT_INPUT"                     = var.input_storage_container_id == null ? azurerm_storage_container.input[0].id : var.input_storage_container_id
        "AZCOPY_ACTIVE_DIRECTORY_ENDPOINT" = var.azure_active_directory_endpoint
        "DEBUG_LOG"                        = "false"
      }
      secure_environment_variables = {
        "PFX_B64" = var.application_pfx_b64
      }
    }
  ]

  log_analytics_workspace = var.log_analytics_workspace
}
