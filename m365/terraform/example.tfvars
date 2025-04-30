contact_emails = {
  me = {
    email = "me@example.com"
  }
}

resource_group_name           = "myresourcegroup"
terraform_azurerm_environment = "public"
location                      = "East US"
schedule_interval             = "Week"
app_name                      = "ScubaRuanders"

log_analytics_workspace_internet_ingestion_enabled = true
log_analytics_workspace_internet_query_enabled     = true