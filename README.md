# bayers_hackathon

This repository contains planning artifacts and starter IaC/CI-CD assets for the healthcare microservices hackathon architecture.

## Contents

- `architecture-plan.md`: Delivery plan, requirements, system boundary, and architecture diagram for Azure AKS with Azure DNS, HPA, and a two-gateway pattern.
- `terraform/cicd`: Terraform configuration to create Azure resources needed for GitHub Actions OIDC using a user-assigned managed identity.
- `.github/workflows/terraform-cicd.yml`: GitHub Actions workflow for Terraform fmt/validate/plan/apply authenticated through Azure OIDC.

## Azure OIDC + Managed Identity setup (Terraform)

1. Copy `terraform/cicd/terraform.tfvars.example` to `terraform/cicd/terraform.tfvars` and update values.
2. Run Terraform from `terraform/cicd` to provision:
   - resource group for CI/CD identity assets,
   - user-assigned managed identity,
   - federated credentials for GitHub token exchange,
   - required Azure role assignments.
3. Save Terraform outputs and configure GitHub repository secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

After that, PRs run `terraform plan` and pushes to `main` run `terraform apply` via `.github/workflows/terraform-cicd.yml`.
