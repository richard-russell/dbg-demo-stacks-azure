# Single landing zone component — one per deployment
component "landing_zone" {
  source = "./modules/landing-zone"

  inputs = {
    name            = "stack-${var.lz_name}-${var.environment}"
    environment     = var.environment
    location        = var.lz_location
    subscription_id = var.lz_subscription_id
    extra_tags      = var.extra_tags
  }

  providers = {
    azurerm.lz = provider.azurerm.lz
    azuread    = provider.azuread.this
  }
}

# Single shared networking component
component "shared_network" {
  source = "./modules/shared-network"

  inputs = {
    name       = "stack-${var.lz_name}-network-${var.environment}"
    location   = var.network_location
    extra_tags = var.extra_tags
  }

  providers = {
    azurerm.network = provider.azurerm.network
  }
}
