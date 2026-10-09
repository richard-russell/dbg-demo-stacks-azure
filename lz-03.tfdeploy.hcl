deployment "lz_03" {
  inputs = {
    lz_name            = "lz-03"
    lz_subscription_id = "00000000-0000-0000-0000-000000000030" # TODO: lz_03 subscription ID
    lz_client_id       = "00000000-0000-0000-0000-000000000031" # TODO: lz_03 app reg client ID
    lz_location        = "uksouth"

    environment = "dev"

    tenant_id               = local.tenant_id
    network_subscription_id = local.network_subscription_id
    network_client_id       = local.network_client_id
    network_location        = local.network_location
    azuread_client_id       = local.azuread_client_id

    identity_token = identity_token.azure.jwt

    extra_tags = merge(local.common_extra_tags, { Deployment = "lz-03", Environment = "dev" })
  }

  deployment_group = deployment_group.dev
}
