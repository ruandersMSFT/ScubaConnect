- Running a terraform init inside the "root module" of the m365/terraform folder initializes with the latest published provider versions because there are no provider version contrainsts in place.  As of April 22 2025, initializing in this folder downloads AzureRM Provider 4.26.0 and AzureAD Provider 3.3.0.  Consider that Terraform [modules should declare their own provider requirements](https://developer.hashicorp.com/terraform/language/modules/develop/providers#provider-version-constraints-in-modules) to establish provider version contraints, given that the code is currently written for AzureRM 3.98.0 and may not be version compatible yet with AzureRM 4.x providers as written.
- Use of the ~> operator on versions to only allow incrementing in the right most component of a version can be used to help avoid major upgrades occuring (major versions have more impacting changes), such as the day where Hashicorp releases AzureRM version 5 series modules (currently version 4).  Ensure that provider versions follow this to manage major release upgrades. [Best Practices for Provider Versions](https://developer.hashicorp.com/terraform/language/providers/requirements#best-practices-for-provider-versions)
- The property `enable_https_traffic_only` has been superseded by `https_traffic_only_enabled` and will be removed in v4.0 of the AzureRM Provider.
- Upgrade AzureRM Provider from 3.x to 4.x ([Release v3.98.0 · hashicorp/terraform-provider-azurerm](https://github.com/hashicorp/terraform-provider-azurerm/releases/tag/v3.98.0) from Apr 4 2024 to current 4.26)
- Upgrade AzureAD Provider from 2.x to 3.x ([Release v2.47.0 · hashicorp/terraform-provider-azuread](https://github.com/hashicorp/terraform-provider-azuread/releases/tag/v2.47.0) from Dec 14 2023 to current 3.3)
- Upgrade AzureAD Provider from 2.x to 3.x ([Release v2.47.0 · hashicorp/terraform-provider-azuread](https://github.com/hashicorp/terraform-provider-azuread/releases/tag/v2.47.0) from Dec 14 2023 to current 3.3)
- Upgrade Terraform required version from [Release v1.1.0 · hashicorp/terraform](https://github.com/hashicorp/terraform/releases/tag/v1.1.0) from Dec 8 2021 to current 1.11.4
- Based on previous statement that the "root module" should control the Terraform Version requirements and the observation that the variables file code is having to be duplicated in the "Envrionment" folder as well as the Provider setup in each Environment folder (only to call the root module via a "../.." reference), the code should be restructured to place the provider setup at the root as well as discontinue the duplication of variables files that are the same.  Consider that the Terraform code as written/existing is "compatible" with a particular version of the Terraform Providers, thus we want that manged at the root.  The Environment is just settings provided to the deployment, not actual Terraform implementation.  Thus, the design goal here is that we are binding the root to the Terraform provider versioning / setup, and the environment is just that -- only environment, no code, no version control of the code itself.  An example solution where you can see this in practice is the Microsoft Pub Sec Info Assistant solution in which the [Providers are configured in the root of the Terraform code](https://github.com/microsoft/PubSec-Info-Assistant/blob/main/infra/providers.tf) but the [environments are only environment configuration (not terraform code itself)](https://github.com/microsoft/PubSec-Info-Assistant/blob/main/scripts/environments/local.env.example).  This will also aide in future maintainability to the Terraform code base for future upgrades, in which changes to the "environment" file may not be needed but the Terraform code is modified to updated providers, new features, etc.  This restructure is going to be problematic with the Terraform state file, which is why managing this structure from the onset is critical.  We will have to provide Terraform state management commands (remove and export) here to customers to "move to the next release" so that Terraform doesn't destroy and recreate Azure Resources.  
- Bug fix on output for correct id for input_storage_container_id
- Add Environment to Variable
- Add cross_tenant_replication_enabled to azurerm_storage_account 

Todo

- Incorporate PowerBI changes
- Azure Gov AzureRM Provider environment setting in documentation
- Is Azure Gov local variables vs provider?
- Attributes for AzureRM 4 resources
- Consider repetative api calls due to multiple data current scope resources
- Consider buildout of parameters (consumption of Azure Verified Modules?)
- Consider standard sku KeyVault (not hsm backed)





terraform state mv module.scuba_connect.azurerm_resource_group.rg azurerm_resource_group.rg

terraform state mv module.scuba_connect.module.app.azuread_application.app[0] module.app.azuread_application.app 

terraform state mv module.scuba_connect.module.app.azuread_application_certificate.app_cert[0] module.app.azuread_application_certificate.app_cert[0]

terraform state mv module.scuba_connect.module.app.azuread_service_principal.app[0] module.app.azuread_service_principal.app[0]

terraform state mv module.scuba_connect.module.app.azurerm_key_vault.vault module.app.azurerm_key_vault.vault

terraform state mv module.scuba_connect.module.app.azurerm_key_vault_certificate.cert module.app.azurerm_key_vault_certificate.cert 

terraform state mv module.scuba_connect.module.app.local_file.scuba_pem_file module.app.local_file.scuba_pem_file

terraform state mv module.scuba_connect.module.app.time_rotating.cert_rotation module.app.time_rotating.cert_rotation

terraform state mv module.scuba_connect.module.container.azurerm_automation_account.runner_aa module.container.azurerm_automation_account.runner_aa

terraform state mv module.scuba_connect.module.container.azurerm_automation_job_schedule.runner_job_schedule module.container.azurerm_automation_job_schedule.runner_job_schedule

terraform state mv module.scuba_connect.module.container.azurerm_automation_runbook.runner_book module.container.azurerm_automation_runbook.runner_book

terraform state mv module.scuba_connect.module.container.azurerm_automation_schedule.runner_schedule module.container.azurerm_automation_schedule.runner_schedule 

terraform state mv module.scuba_connect.module.container.azurerm_log_analytics_saved_search.container_search module.container.azurerm_log_analytics_saved_search.container_search

terraform state mv module.scuba_connect.module.container.azurerm_log_analytics_saved_search.last_run_search module.container.azurerm_log_analytics_saved_search.last_run_search

terraform state mv module.scuba_connect.module.container.azurerm_monitor_action_group.action_group module.container.azurerm_monitor_action_group.action_group

terraform state mv module.scuba_connect.module.container.azurerm_monitor_scheduled_query_rules_alert_v2.exit_alert module.container.azurerm_monitor_scheduled_query_rules_alert_v2.exit_alert

terraform state mv module.scuba_connect.module.container.azurerm_role_assignment.aa_system_id module.container.azurerm_role_assignment.aa_system_id

terraform state mv module.scuba_connect.module.container.azurerm_role_assignment.app_storage_role[0] module.container.azurerm_role_assignment.app_storage_role

terraform state mv module.scuba_connect.module.container.azurerm_role_assignment.law_access module.container.azurerm_role_assignment.law_access

terraform state mv module.scuba_connect.module.container.azurerm_role_definition.start_container_role module.container.azurerm_role_definition.start_container_role

terraform state mv module.scuba_connect.module.container.azurerm_storage_account.storage[0] module.container.azurerm_storage_account.storage[0]

terraform state mv module.scuba_connect.module.container.azurerm_storage_container.input[0] module.container.azurerm_storage_container.input[0]

terraform state mv module.scuba_connect.module.container.azurerm_storage_container.output[0] module.container.azurerm_storage_container.output[0]

terraform state mv module.scuba_connect.azurerm_log_analytics_workspace.monitor_law azurerm_log_analytics_workspace.monitor_law

terraform state mv 'module.scuba_connect.module.container.azurerm_container_group.aci["adhoc"]' 'module.container.azurerm_container_group.aci["adhoc"]'

terraform state mv 'module.scuba_connect.module.container.azurerm_container_group.aci["scheduled"]' 'module.container.azurerm_container_group.aci["scheduled"]'

# terraform state mv module.scuba_connect.module.container.azurerm_storage_blob.tenants["myorg.onmicrosoft.com.yaml"] 

