variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "federated_subjects" {
  type = list(string)
  default = [
    "repo:ORG/REPO:ref:refs/heads/main",
    "repo:ORG/REPO:pull_request"
  ]
}

variable "managed_identity_name" {
  type    = string
  default = "mi-github-terraform"
}

variable "terraform_state_storage_account_id" {
  type    = string
  default = null
}

variable "additional_role_assignments" {
  type = list(object({
    scope                = string
    role_definition_name = string
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
