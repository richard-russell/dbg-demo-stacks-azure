deployment "lz_01" {
  inputs = {
    lz_name            = "lz-01"
    lz_subscription_id = "00000000-0000-0000-0000-000000000010" # TODO: lz_01 subscription ID
    lz_client_id       = "00000000-0000-0000-0000-000000000011" # TODO: lz_01 app reg client ID
    lz_location        = "uksouth"

    environment = "dev"

    tenant_id               = local.tenant_id
    network_subscription_id = local.network_subscription_id
    network_client_id       = local.network_client_id
    network_location        = local.network_location
    azuread_client_id       = local.azuread_client_id

    identity_token = identity_token.azure.jwt

    extra_tags = merge(local.common_extra_tags, { Deployment = "lz-01", Environment = "dev" })
  }

  deployment_group = deployment_group.dev
}
