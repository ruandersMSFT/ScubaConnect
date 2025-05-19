locals {
  aa_prefix    = "${local.prefix}-runner-automation-"
  aa_unique_id = substr(replace(local.app_client_id, "-", ""), 0, 50 - length(local.aa_prefix))
}

data "local_file" "runner_runbook" {
  filename = "${path.module}/runner_runbook.ps1"
}

module "runner" {
  source  = "Azure/avm-res-automation-automationaccount/azurerm"
  version = "0.1.0"

  automation_runbooks = {
    runbook = {
      description                = "Runbook for starting scheduled ${local.prefix} container instance"
      name                       = "${local.prefix}-runner-runbook"
      content                    = data.local_file.runner_runbook.content
      runbook_type               = "PowerShell72"
      log_analytics_workspace_id = module.log_analytics_workspace.resource_id
      log_progress               = true
      log_verbose                = true
    }
  }
  automation_schedules = {
    runner_schedule = {
      frequency   = var.schedule_interval
      name        = "${local.prefix}-runner-schedule"
      description = "Schedule to run ${local.prefix} container instance"
      timezone    = "Etc/UTC"
    }
  }
  name                          = "${local.aa_prefix}${local.aa_unique_id}"
  location                      = module.resource_group.resource.location
  resource_group_name           = module.resource_group.resource.name
  public_network_access_enabled = true
  sku                           = "Basic"
  enable_telemetry              = false
  managed_identities = {
    system_assigned = true
  }
}

# Assigns the role to the automation account
resource "azurerm_role_assignment" "aa_system_id" {
  scope              = module.resource_group.resource_id
  role_definition_id = azurerm_role_definition.start_container_role.role_definition_resource_id
  principal_id       = module.runner.system_assigned_mi_principal_id
}

# Assigns the schedule to the runbook
resource "azurerm_automation_job_schedule" "runner_job_schedule" {
  resource_group_name     = module.resource_group.resource.name
  automation_account_name = module.runner.automation_account_name
  schedule_name           = "todo" # azurerm_automation_schedule.runner_schedule.name
  runbook_name            = "todo" # azurerm_automation_runbook.runner_book.name
  parameters = {
    # must be all lowercase here: https://github.com/Azure/azure-sdk-for-go/issues/4780
    "resourcegroupname"     = module.resource_group.resource.name
    "containerinstancename" = module.container_group["scheduled"].resource.name
    "environment"           = local.azure_environment
  }
}
