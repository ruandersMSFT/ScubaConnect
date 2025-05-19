# Role which allows the script to start Azure Container Instances
resource "azurerm_role_definition" "start_container_role" {
  name  = "${local.prefix}-start-aci-${local.app_client_id}"
  scope = module.resource_group.resource_id

  permissions {
    actions = ["Microsoft.ContainerInstance/containerGroups/start/action"]
  }
}
