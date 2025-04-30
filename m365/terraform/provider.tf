# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
  }

  required_version = ">= 1.11.4"
}

provider "azurerm" {
  features {}

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#environment-1
  # The environment can be set to "public" for the global Azure cloud, or "usgovernment" for the US Government cloud. 
  environment = var.environment

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#subscription_id-1
  # The subscription_id is the unique identifier for your Azure subscription. This can also be sourced from the ARM_SUBSCRIPTION_ID Environment Variable.
  subscription_id = "070cfebd-3e63-42a5-ba50-58de1db7496e" # "<YOUR_SUBSCRIPTION_UUID>"
}

provider "azuread" {

}