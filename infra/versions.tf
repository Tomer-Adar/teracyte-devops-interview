terraform {
  required_version = ">= 1.6, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Production: an azurerm backend (separate storage account, blob lease locking), e.g.
  # backend "azurerm" { resource_group_name = "tfstate" storage_account_name = "..." container_name = "tfstate" key = "storage.tfstate" use_azuread_auth = true }
  # Left out so `terraform init -backend=false` / validate needs no cloud access.
}

provider "azurerm" {
  features {}
  # Containers are managed via the data plane with Entra ID because shared keys are disabled.
  storage_use_azuread = true
}
