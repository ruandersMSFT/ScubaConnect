data "azuread_client_config" "current" {}

data "azurerm_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

data "azuread_service_principal" "o365exchange" {
  client_id = data.azuread_application_published_app_ids.well_known.result.Office365ExchangeOnline
}

data "azuread_service_principal" "sharepoint" {
  client_id = data.azuread_application_published_app_ids.well_known.result.Office365SharePointOnline
}

data "azuread_application" "app" {
  count        = var.create_app ? 0 : 1
  display_name = var.app_name
}

data "azuread_service_principal" "app" {
  count        = var.create_app ? 0 : 1
  display_name = var.app_name
}
