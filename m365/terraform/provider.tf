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
  subscription_id = "070cfebd-3e63-42a5-ba50-58de1db7496e" # "<YOUR_SUBSCRIPTION_UUID>"
}

provider "azuread" {

}