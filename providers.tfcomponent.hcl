required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 4.0"
  }
  azuread = {
    source  = "hashicorp/azuread"
    version = "~> 3.0"
  }
}

# One provider instance per landing zone — keyed by lz_configs map key
provider "azurerm" "lz" {
  for_each = var.lz_configs

  config {
    subscription_id = each.value.subscription_id
    tenant_id       = var.tenant_id
    client_id       = each.value.client_id
    use_oidc        = true
    oidc_token      = var.identity_token_lz
  }
}

# Single shared provider for the network hub subscription
provider "azurerm" "network" {
  config {
    subscription_id = var.network_subscription_id
    tenant_id       = var.tenant_id
    client_id       = var.network_client_id
    use_oidc        = true
    oidc_token      = var.identity_token_network
  }
}

# Single shared Azure AD provider
provider "azuread" "this" {
  config {
    tenant_id  = var.tenant_id
    client_id  = var.azuread_client_id
    use_oidc   = true
    oidc_token = var.identity_token_azuread
  }
}
