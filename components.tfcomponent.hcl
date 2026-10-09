# One landing zone component instance per entry in lz_configs
component "landing_zone" {
  for_each = var.lz_configs

  source = "./modules/landing-zone"

  inputs = {
    name            = "stack-${each.key}-${var.environment}"
    environment     = var.environment
    location        = each.value.location
    subscription_id = each.value.subscription_id
    extra_tags      = var.extra_tags
  }

  providers = {
    azurerm.lz = provider.azurerm.lz[each.key]
    azuread    = provider.azuread.this
  }
}

# Single shared networking component
component "shared_network" {
  source = "./modules/shared-network"

  inputs = {
    name       = "stack-shared-network-${var.environment}"
    location   = var.network_location
    extra_tags = var.extra_tags
  }

  providers = {
    azurerm.network = provider.azurerm.network
  }
}
