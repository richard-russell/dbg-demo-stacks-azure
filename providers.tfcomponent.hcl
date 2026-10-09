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

# Per-deployment landing zone provider — one instance, authenticated as the LZ app registration
provider "azurerm" "lz" {
  config {
    features {}

    subscription_id = var.lz_subscription_id
    tenant_id       = var.tenant_id
    client_id       = var.lz_client_id
    use_oidc        = true
    oidc_token      = var.identity_token
  }
}

# Shared provider for the network hub subscription
provider "azurerm" "network" {
  config {
    features {}

    subscription_id = var.network_subscription_id
    tenant_id       = var.tenant_id
    client_id       = var.network_client_id
    use_oidc        = true
    oidc_token      = var.identity_token
  }
}

# Shared Azure AD provider
provider "azuread" "this" {
  config {
    tenant_id  = var.tenant_id
    client_id  = var.azuread_client_id
    use_oidc   = true
    oidc_token = var.identity_token
  }
}
