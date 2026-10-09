# -----------------------------------------------------------------------------
# Azure Workload Identity — one token per trust boundary
# Azure OIDC audience for all three tokens is "api://AzureADTokenExchange"
# -----------------------------------------------------------------------------

identity_token "azurerm_lz" {
  audience = ["api://AzureADTokenExchange"]
}

identity_token "azurerm_network" {
  audience = ["api://AzureADTokenExchange"]
}

identity_token "azuread" {
  audience = ["api://AzureADTokenExchange"]
}

# -----------------------------------------------------------------------------
# Shared configuration values
# Replace placeholder values with real app registration details once created
# -----------------------------------------------------------------------------

locals {
  tenant_id = "00000000-0000-0000-0000-000000000000" # TODO: replace with real tenant ID

  # Shared network provider credentials
  network_subscription_id = "00000000-0000-0000-0000-000000000001" # TODO: network subscription
  network_client_id       = "00000000-0000-0000-0000-000000000002" # TODO: network app reg client ID
  network_location        = "uksouth"

  # Azure AD provider credentials
  azuread_client_id = "00000000-0000-0000-0000-000000000003" # TODO: azuread app reg client ID

  # Per-LZ subscription IDs and client IDs
  lz_subscription_ids = {
    lz_01 = "00000000-0000-0000-0000-000000000010" # TODO: lz_01 subscription ID
    lz_02 = "00000000-0000-0000-0000-000000000020" # TODO: lz_02 subscription ID
    lz_03 = "00000000-0000-0000-0000-000000000030" # TODO: lz_03 subscription ID
  }

  lz_client_ids = {
    lz_01 = "00000000-0000-0000-0000-000000000011" # TODO: lz_01 app reg client ID
    lz_02 = "00000000-0000-0000-0000-000000000021" # TODO: lz_02 app reg client ID
    lz_03 = "00000000-0000-0000-0000-000000000031" # TODO: lz_03 app reg client ID
  }

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
