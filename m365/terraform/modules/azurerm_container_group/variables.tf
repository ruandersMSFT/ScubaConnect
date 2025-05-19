variable "containers" {
  type = list(
    object({
      cpu                          = number
      environment_variables        = map(string)
      image                        = string
      memory                       = number
      name                         = string
      secure_environment_variables = map(string)
    })
  )
  description = "List of containers to run in the container group"
}

variable "image_registry_credential" {
  type = object({
    server   = string
    username = string
    password = string
  })
  default     = null
  description = "Credentials for logging into registry with container image"
}

variable "ip_address_type" {
  type        = string
  description = "IP address type for the container group"
}

variable "location" {
  type        = string
  description = "Location of the resource group"
}

variable "log_analytics_workspace" {
  type = object({
    id                 = string
    workspace_id       = string
    primary_shared_key = string
  })
  description = "Log Analytics Workspace container should write logs to"

}

variable "name" {
  type = string
}

variable "os_type" {
  type        = string
  description = "Operating system type for the container group"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "restart_policy" {
  type        = string
  description = "Restart policy for the container group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets used for storage and Azure Container Instances"
  default     = null
}