deployment "lz_01" {
  inputs = {
    # Single-entry map so for_each on provider/component resolves to exactly one instance
    lz_configs = {
      lz_01 = {
        subscription_id = local.lz_subscription_ids["lz_01"]
        client_id       = local.lz_client_ids["lz_01"]
        location        = "uksouth"
      }
    }

    environment = "dev"

    tenant_id               = local.tenant_id
    network_subscription_id = local.network_subscription_id
    network_client_id       = local.network_client_id
    network_location        = local.network_location
    azuread_client_id       = local.azuread_client_id

    identity_token_lz      = identity_token.azurerm_lz.jwt
    identity_token_network = identity_token.azurerm_network.jwt
    identity_token_azuread = identity_token.azuread.jwt

    extra_tags = merge(local.common_extra_tags, { Deployment = "lz-01", Environment = "dev" })
  }

  deployment_group = deployment_group.dev
}
