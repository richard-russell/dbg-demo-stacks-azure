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

# Link component: reads from the network hub (azurerm.network) and writes into
# the LZ Key Vault (azurerm.lz) — demonstrates both providers in a single module,
# mirroring the customer's module "lz1" { providers = { azurerm.lz, azurerm.network } } pattern
component "lz_network_link" {
  source = "./modules/lz-network-link"

  inputs = {
    # Consumed from component.shared_network — creates an explicit dependency
    network_resource_group_name = component.shared_network.resource_group_name
    # Consumed from component.landing_zone — creates an explicit dependency
    key_vault_id = component.landing_zone.key_vault_id
    extra_tags   = var.extra_tags
  }

  providers = {
    azurerm.lz      = provider.azurerm.lz
    azurerm.network = provider.azurerm.network
  }
}
