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