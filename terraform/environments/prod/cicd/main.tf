module "github_oidc_identity" {
  source = "../../../modules/github_oidc_identity"

  subscription_id                    = var.subscription_id
  resource_group_name                = var.resource_group_name
  location                           = var.location
  github_org                         = var.github_org
  github_repo                        = var.github_repo
  federated_subjects                 = var.federated_subjects
  managed_identity_name              = var.managed_identity_name
  terraform_state_storage_account_id = var.terraform_state_storage_account_id
  additional_role_assignments        = var.additional_role_assignments
  tags                               = var.tags
}
