module "monitor_law" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"

  enable_telemetry                                   = false
  name                                               = "${local.name}-monitor-loganalytics"
  location                                           = module.resource_group.resource.location
  resource_group_name                                = module.resource_group.name
  log_analytics_workspace_internet_ingestion_enabled = var.log_analytics_workspace_internet_ingestion_enabled
  log_analytics_workspace_internet_query_enabled     = var.log_analytics_workspace_internet_query_enabled
  log_analytics_workspace_sku                        = "PerGB2018"
  log_analytics_workspace_retention_in_days          = 30
}

resource "azurerm_log_analytics_saved_search" "last_run_search" {
  name                       = "lastRunSearch"
  log_analytics_workspace_id = module.monitor_law.resource_id

  category     = "${local.name} Container"
  display_name = "${local.name} Last Run Output"
  query        = <<-QUERY
    let e = toscalar(ContainerEvent_CL | where Message contains "pulling image" | summarize max(TimeGenerated)); 
    union ContainerEvent_CL, ContainerInstanceLog_CL
    | where TimeGenerated > e
    | project TimeGenerated, ContainerGroup_s, Type, Message
    | order by TimeGenerated asc
    QUERY
}

resource "azurerm_log_analytics_saved_search" "container_search" {
  name                       = "containerSearch"
  log_analytics_workspace_id = module.monitor_law.resource_id

  category     = "${local.name} Container"
  display_name = "${local.name} Container Logs (7d)"
  query        = <<-QUERY
    union ContainerEvent_CL, ContainerInstanceLog_CL
    | where TimeGenerated > ago(7d)
    | order by TimeGenerated
    QUERY
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "${local.name} Container Alerts"
  resource_group_name = module.resource_group.name
  short_name          = substr(local.name, 0, 12)
  dynamic "email_receiver" {
    for_each = var.contact_emails
    content {
      name          = "email ${email_receiver.value.email}"
      email_address = email_receiver.value.email
    }
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "exit_alert" {
  name                = "exit-code-alert"
  location            = module.resource_group.resource.location
  resource_group_name = module.resource_group.name

  evaluation_frequency = "PT15M"
  window_duration      = "PT15M"
  scopes               = [module.monitor_law.resource_id]
  severity             = 2
  criteria {
    query                   = <<-QUERY
        ContainerEvent_CL
        | where Message contains "Terminating with exit code 1"
      QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"
  }

  description  = "Alerts when ${local.name} container has non-zero exit code."
  display_name = "${local.name} Container Exit Code Alert"

  action {
    action_groups = [azurerm_monitor_action_group.action_group.id]
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "law_access" {
  scope                = module.monitor_law.resource_id
  role_definition_name = "Reader"
  principal_id         = azurerm_monitor_scheduled_query_rules_alert_v2.exit_alert.identity[0].principal_id
}
