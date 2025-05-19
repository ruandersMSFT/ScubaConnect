resource "azurerm_container_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = var.ip_address_type
  subnet_ids          = var.subnet_ids
  os_type             = var.os_type
  restart_policy      = var.restart_policy

  dynamic "image_registry_credential" {
    for_each = var.image_registry_credential == null ? [] : [1]
    content {
      server   = var.image_registry_credential.server
      username = var.image_registry_credential.username
      password = var.image_registry_credential.password
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = var.log_analytics_workspace.workspace_id
      workspace_key = var.log_analytics_workspace.primary_shared_key
    }
  }

  dynamic "container" {
    for_each = var.containers
    content {
      cpu                          = container.value["cpu"]
      environment_variables        = container.value["environment_variables"]
      image                        = container.value["image"]
      memory                       = container.value["memory"]
      name                         = container.value["name"]
      secure_environment_variables = container.value["secure_environment_variables"]
    }
  }
}
