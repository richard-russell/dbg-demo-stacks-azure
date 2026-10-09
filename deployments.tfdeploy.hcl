# -----------------------------------------------------------------------------
# Azure Workload Identity
# One token covers all provider instances — same audience "api://AzureADTokenExchange"
# Each provider uses a different client_id to authenticate to its own app registration
# -----------------------------------------------------------------------------

identity_token "azure" {
  audience = ["api://AzureADTokenExchange"]
}

# -----------------------------------------------------------------------------
# Shared configuration values
# Replace placeholder values with real app registration details once created
# -----------------------------------------------------------------------------

locals {
  tenant_id = "00000000-0000-0000-0000-000000000000" # TODO: replace with real tenant ID

  # Shared network provider credentials
  network_subscription_id = "00000000-0000-0000-0000-000000000001" # TODO: network subscription ID
  network_client_id       = "00000000-0000-0000-0000-000000000002" # TODO: network app reg client ID
  network_location        = "uksouth"

  # Azure AD provider credentials
  azuread_client_id = "00000000-0000-0000-0000-000000000003" # TODO: azuread app reg client ID

  common_extra_tags = { Demo = "demo-3-stacks-azure", ManagedBy = "Terraform Stacks" }
}

# -----------------------------------------------------------------------------
# Deployment Groups & Auto-Approval
# -----------------------------------------------------------------------------

deployment_auto_approve "safe_changes" {
  check {
    condition = context.plan.applyable
    reason    = "Plan must be applyable without errors"
  }

  check {
    condition = context.plan.changes.remove == 0
    reason    = "Plans with resource deletions require manual approval"
  }
}

deployment_group "dev" {
  auto_approve_checks = [deployment_auto_approve.safe_changes]
}

deployment_group "prod" {
  # Manual approval required for production changes
}
