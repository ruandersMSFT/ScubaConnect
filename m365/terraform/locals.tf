locals {
  prefix                          = var.prefix_override != null ? var.prefix_override : replace(lower(var.app_name), " ", "-")
  azure_active_directory_endpoint = var.terraform_azurerm_environment == "public" ? "https://login.microsoftonline.com" : var.terraform_azurerm_environment == "usgovernment" ? "https://login.microsoftonline.us" : null
  azure_environment               = var.terraform_azurerm_environment == "public" ? "AzureCloud" : var.terraform_azurerm_environment == "usgovernment" ? "AzureUSGovernment" : null
  azure_portal_endpoint           = var.terraform_azurerm_environment == "public" ? "https://portal.azure.com" : var.terraform_azurerm_environment == "usgovernment" ? "https://portal.azure.us" : null

  app_client_id               = var.create_app ? azuread_application.app[0].client_id : data.azuread_application.app[0].client_id
  sp_object_id                = var.create_app ? azuread_service_principal.app[0].object_id : data.azuread_service_principal.app[0].object_id
  input_storage_container_id  = var.input_storage_container_id == null ? azurerm_storage_container.input[0].id : var.input_storage_container_id
  output_storage_container_id = var.output_storage_container_id == null ? azurerm_storage_container.output[0].id : var.output_storage_container_id

  ip_rules = try(var.vnet.allowed_access_ip_list, null)
}
