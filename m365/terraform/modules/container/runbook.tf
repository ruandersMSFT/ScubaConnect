locals {
  aa_prefix    = "${var.resource_prefix}-runner-automation-"
  aa_unique_id = substr(replace(var.application_client_id, "-", ""), 0, 50 - length(local.aa_prefix))
}

module "runner" {
  source  = "Azure/avm-res-automation-automationaccount/azurerm"
  version = "0.1.0"

  automation_runbooks = {
    runbook = {
      description                = "Runbook for starting scheduled ${var.resource_prefix} container instance"
      name                       = "${var.resource_prefix}-runner-runbook"
      content                    = data.local_file.runner_runbook.content
      runbook_type               = "PowerShell72"
      log_analytics_workspace_id = var.log_analytics_workspace.id
      log_progress               = true
      log_verbose                = true
    }
  }
  automation_schedules = {
    runner_schedule = {
      frequency               = var.schedule_interval
      name        = "${var.resource_prefix}-runner-schedule"
      description = "Schedule to run ${var.resource_prefix} container instance"
      timezone = "Etc/UTC"
    }
  }
  name                          = "${local.aa_prefix}${local.aa_unique_id}"
  location                      = var.resource_group.location
  resource_group_name           = var.resource_group.name
  public_network_access_enabled = true
  sku                           = "Basic"
  enable_telemetry              = false
  managed_identities = {
    system_assigned = true
  }
}

# Role which allows the script to start Azure Container Instances
resource "azurerm_role_definition" "start_container_role" {
  name  = "${var.resource_prefix}-start-aci-${var.application_client_id}"
  scope = var.resource_group.id

  permissions {
    actions = ["Microsoft.ContainerInstance/containerGroups/start/action"]
  }
}

# Assigns the role to the automation account
resource "azurerm_role_assignment" "aa_system_id" {
  scope              = var.resource_group.id
  role_definition_id = azurerm_role_definition.start_container_role.role_definition_resource_id
  principal_id       = module.runner.system_assigned_mi_principal_id
}

data "local_file" "runner_runbook" {
  filename = "${path.module}/runner_runbook.ps1"
}

# Assigns the schedule to the runbook
resource "azurerm_automation_job_schedule" "runner_job_schedule" {
  resource_group_name     = var.resource_group.name
  automation_account_name = module.runner.automation_account_name
  schedule_name           = "todo" # azurerm_automation_schedule.runner_schedule.name
  runbook_name            = "todo" # azurerm_automation_runbook.runner_book.name
  parameters = {
    # must be all lowercase here: https://github.com/Azure/azure-sdk-for-go/issues/4780
    "resourcegroupname"     = var.resource_group.name
    "containerinstancename" = module.container_group["scheduled"].resource.name
    "environment"           = var.azure_environment
  }
}