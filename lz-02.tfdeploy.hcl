deployment "lz_02" {
  inputs = {
    lz_name            = "lz-02"
    lz_subscription_id = "30e50df1-bf94-4972-98a1-6fae5960a1d9" # TODO: lz_02 subscription ID
    lz_client_id       = "045d241f-5a2a-44ef-b550-42bf8ac31161" # TODO: lz_02 app reg client ID
    lz_location        = "uksouth"

    environment = "dev"

    tenant_id               = local.tenant_id
    network_subscription_id = local.network_subscription_id
    network_client_id       = local.network_client_id
    network_location        = local.network_location
    azuread_client_id       = local.azuread_client_id

    identity_token = identity_token.azure.jwt

    extra_tags = merge(local.common_extra_tags, { Deployment = "lz-02", Environment = "dev" })
  }

  deployment_group = deployment_group.dev
}
