output "resource" {
  description = <<-EOT
  "This is the full output for the Container Group resource. This is the default output for the module following AVM standards. Review the examples below for the correct output to use in your module."
  Examples:
  - module.container_group.resource.id
  - module.container_group.resource.name
EOT
  sensitive   = true
  value       = azurerm_container_group.this
}

output "resource_id" {
  description = "This is the full output for the Container Group resource ID. This is the default output for the module following AVM standards. Review the examples below for the correct output to use in your module."
  value       = azurerm_container_group.this.id
}
