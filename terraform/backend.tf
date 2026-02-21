terraform {
  backend "azurerm" {
    resource_group_name  = "rg-dev-microservice"
    storage_account_name = "terraformstatefilelock"
    container_name       = "statefile"
    key                  = "dev/terraform.tfstate"
  }

}
