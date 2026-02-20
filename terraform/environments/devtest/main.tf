############################################
# Terraform & Provider Configuration
############################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

############################################
# Resource Group
############################################

resource "azurerm_resource_group" "rg" {
  name     = "my-eastus-rg"
  location = "East US"
}
