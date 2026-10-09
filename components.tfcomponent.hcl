# -----------------------------------------------------------------------------
# Removed blocks — destroy resources from the three previous components before
# they are replaced by lz_hub. Leave these in place until all deployment destroy
# runs have completed, then remove along with the old module directories.
# -----------------------------------------------------------------------------

removed {
  from   = component.landing_zone
  source = "./modules/landing-zone"

  providers = {
    azurerm.lz = provider.azurerm.lz
    azuread    = provider.azuread.this
  }
}

removed {
  from   = component.shared_network
  source = "./modules/shared-network"

  providers = {
    azurerm.network = provider.azurerm.network
  }
}

removed {
  from   = component.lz_network_link
  source = "./modules/lz-network-link"

  providers = {
    azurerm.lz      = provider.azurerm.lz
    azurerm.network = provider.azurerm.network
  }
}

# -----------------------------------------------------------------------------
# Single component per deployment.
# The lz-hub module receives both azurerm.lz and azurerm.network, plus azuread,
# mirroring the customer's pattern:
#   module "lz1" {
#     providers = {
#       azurerm.lz      = azurerm.lz1
#       azurerm.network = azurerm.network
#       azuread         = azuread
#     }
#   }
component "lz_hub" {
  source = "./modules/lz-hub"

  inputs = {
    lz_name            = var.lz_name
    environment        = var.environment
    lz_location        = var.lz_location
    lz_subscription_id = var.lz_subscription_id
    network_location   = var.network_location
    extra_tags         = var.extra_tags
  }

  providers = {
    azurerm.lz      = provider.azurerm.lz
    azurerm.network = provider.azurerm.network
    azuread         = provider.azuread.this
  }
}
