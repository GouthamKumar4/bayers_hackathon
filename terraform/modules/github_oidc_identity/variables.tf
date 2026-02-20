variable "subscription_id" {
  description = "Azure subscription ID used by the GitHub OIDC managed identity."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that stores CI/CD identity resources."
  type        = string
}

variable "location" {
  description = "Azure region for CI/CD identity resources."
  type        = string
}

variable "github_org" {
  description = "GitHub organization or user that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "federated_subjects" {
  description = "GitHub OIDC subjects that can exchange tokens for this identity. Use ORG/REPO placeholder if desired."
  type        = list(string)
}

variable "managed_identity_name" {
  description = "User-assigned managed identity name for GitHub Actions."
  type        = string
}

variable "terraform_state_storage_account_id" {
  description = "Optional storage account resource ID used for Terraform state role assignment."
  type        = string
  default     = null
}

variable "additional_role_assignments" {
  description = "Additional role assignments for the managed identity."
  type = list(object({
    scope                = string
    role_definition_name = string
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to identity resources."
  type        = map(string)
  default     = {}
}
