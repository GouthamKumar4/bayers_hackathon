# Fill these with your ALREADY-CREATED remote state resources.
# Required values:
resource_group_name  = "rg-dev-microservices"
storage_account_name = "terraformstatefilelock"
container_name       = "statefile"
key                  = "dev/terraform.tfstate"

# Optional (uncomment if you need explicit auth context)
# subscription_id     = "00000000-0000-0000-0000-000000000000"
# tenant_id           = "00000000-0000-0000-0000-000000000000"
# use_azuread_auth    = true