terraform {
  backend "azurerm" {
    resource_group_name  = "rg-dev-microservices"
    storage_account_name = "terraformstatefilelock"
    container_name       = "statefile"
    key                  = "prod/terraform.tfstate"
  }
}