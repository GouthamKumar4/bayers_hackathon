# bayers_hackathon

This repository contains planning artifacts and reusable IaC/CI-CD templates for the healthcare microservices hackathon architecture.

## Repository layout

- `architecture-plan.md`: Delivery plan, requirements, system boundary, and AKS architecture diagram.
- `terraform/modules/github_oidc_identity`: Reusable Terraform module that provisions Azure resources for GitHub OIDC + user-assigned managed identity.
- `terraform/environments/<env>/cicd`: Environment-specific wrappers (`dev`, `staging`, `prod`) that consume the reusable module.
- `.github/workflows/reusable-terraform.yml`: Reusable workflow (`workflow_call`) for Terraform plan/apply.
- `.github/workflows/terraform-cicd.yml`: Consumer workflow for CI events (PR/push).
- `.github/workflows/app-cd-example.yml`: Example of another CD workflow consuming the reusable Terraform workflow before app deployment.

## Terraform: reusable module + environment wrappers

### Why this structure

- **Reusable logic** stays in `terraform/modules/github_oidc_identity`.
- **Environment-specific configuration** stays in `terraform/environments/<env>/cicd`.
- This keeps platform logic DRY while still allowing per-environment subscriptions, tags, and role scopes.

### Bootstrap an environment

1. Copy an env file:
   - `terraform/environments/dev/cicd/terraform.tfvars.example` -> `terraform.tfvars`
2. Set values for your subscription, tenant, repo, and naming.
3. Run Terraform from that env folder.

Example:

```bash
cd terraform/environments/dev/cicd
terraform init
terraform plan
terraform apply
```

## CI/CD with reusable workflow + reviewers

`reusable-terraform.yml` accepts:
- `tf_working_dir`
- `environment`
- `plan_only`

The job uses `environment: <name>`, so required reviewers can be enforced in GitHub environments:

1. Go to **Settings -> Environments**.
2. Create `dev`, `staging`, `prod`.
3. Add **Required reviewers** for each.

When `plan_only: false`, apply steps will be gated by those reviewers automatically.

## How other CD workflows consume provisioning

Use `uses: ./.github/workflows/reusable-terraform.yml` in any workflow before app deploy stages.

Pattern:
1. `platform-provisioning` job calls reusable Terraform workflow.
2. `app-deploy` job depends on provisioning via `needs`.

See `.github/workflows/app-cd-example.yml` for a working template.

## Terraform modules: folder vs separate repo

### Option A: Keep modules in this repo (current setup)
- Best for small/medium teams and fast iteration.
- Simple local references (`source = "../../../modules/..."`).
- Easier change coordination with app and workflow updates.

### Option B: Separate modules repo
- Better for centralized platform governance across many repos.
- Version modules via tags and consume with git source URLs.
- Stronger control and release process, but slightly slower iteration.

https://aws.plainenglish.io/our-terraform-state-got-corrupted-infrastructure-was-unmanageable-ce0ea6fbef41

Recommended path now: keep module in-repo until multiple repositories need the same module, then promote to a dedicated module repository.
