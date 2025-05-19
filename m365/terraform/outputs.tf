output "app_id" {
  description = "APP ID of the application. This should be passed to the install script"
  value       = local.app_client_id
}

output "output_storage_container_id" {
  description = "ID of the output storage account results are written to"
  value       = local.output_storage_container_id
}

output "input_storage_container_id" {
  description = "ID of the input storage account configs are read from"
  value       = local.input_storage_container_id
}

output "sp_object_id" {
  description = "Object ID for the application's Service Principal. This can be used to given additional permissions for reading/writing to custom storage locations"
  value       = local.sp_object_id
}
