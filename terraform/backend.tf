terraform {
  backend "azurerm" {
    resource_group_name  = "rg-dev"
    storage_account_name = "terraformstatefilelock"
    container_name       = "terraformstatefile"
    key                  = "dev/terraform.tfstate"
  }

}
