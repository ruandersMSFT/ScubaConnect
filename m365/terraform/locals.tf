locals {
  name                            = var.prefix_override != null ? var.prefix_override : replace(lower(var.app_name), " ", "-")
  azure_active_directory_endpoint = var.terraform_azurerm_environment == "public" ? "https://login.microsoftonline.com" : var.terraform_azurerm_environment == "usgovernment" ? "https://login.microsoftonline.us" : null
  azure_environment               = var.terraform_azurerm_environment == "public" ? "AzureCloud" : var.terraform_azurerm_environment == "usgovernment" ? "AzureUSGovernment" : null
  azure_portal_endpoint           = var.terraform_azurerm_environment == "public" ? "https://portal.azure.com" : var.terraform_azurerm_environment == "usgovernment" ? "https://portal.azure.us" : null
}
