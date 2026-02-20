output "managed_identity_client_id" {
  description = "Client ID for azure/login in GitHub Actions."
  value       = azurerm_user_assigned_identity.github.client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the GitHub OIDC managed identity."
  value       = azurerm_user_assigned_identity.github.principal_id
}

output "tenant_id" {
  description = "Tenant ID for azure/login in GitHub Actions."
  value       = var.tenant_id
}

output "subscription_id" {
  description = "Subscription ID for azure/login in GitHub Actions."
  value       = var.subscription_id
}

output "federated_subjects" {
  description = "Federated subjects configured for GitHub Actions token exchange."
  value       = local.federated_subject
}
