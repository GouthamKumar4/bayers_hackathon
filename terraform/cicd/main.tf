data "azurerm_client_config" "current" {}

locals {
  repository        = "${var.github_org}/${var.github_repo}"
  federated_subject = [for subject in var.federated_subjects : replace(subject, "ORG/REPO", local.repository)]

  base_role_assignments = [
    {
      scope                = "/subscriptions/${var.subscription_id}"
      role_definition_name = "Contributor"
    },
    {
      scope                = "/subscriptions/${var.subscription_id}"
      role_definition_name = "User Access Administrator"
    }
  ]

  state_role_assignment = var.terraform_state_storage_account_id == null ? [] : [
    {
      scope                = var.terraform_state_storage_account_id
      role_definition_name = "Storage Blob Data Contributor"
    }
  ]

  all_role_assignments = concat(local.base_role_assignments, local.state_role_assignment, var.additional_role_assignments)
}

resource "azurerm_resource_group" "cicd" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_user_assigned_identity" "github" {
  name                = var.managed_identity_name
  location            = azurerm_resource_group.cicd.location
  resource_group_name = azurerm_resource_group.cicd.name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "github" {
  for_each = toset(local.federated_subject)

  name                = "gh-${replace(replace(each.value, ":", "-"), "/", "-")}"
  resource_group_name = azurerm_resource_group.cicd.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.github.id
  subject             = each.value
}

resource "azurerm_role_assignment" "github" {
  for_each = {
    for idx, assignment in local.all_role_assignments :
    "${idx}-${assignment.role_definition_name}" => assignment
  }

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}
