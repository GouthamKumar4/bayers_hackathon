output "managed_identity_client_id" {
  value = module.github_oidc_identity.managed_identity_client_id
}

output "managed_identity_principal_id" {
  value = module.github_oidc_identity.managed_identity_principal_id
}

output "federated_subjects" {
  value = module.github_oidc_identity.federated_subjects
}

output "tenant_id" {
  value = var.tenant_id
}

output "subscription_id" {
  value = var.subscription_id
}
