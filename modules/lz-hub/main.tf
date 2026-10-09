terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.lz, azurerm.network]
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

locals {
  lz_prefix = "stack-${lower(var.lz_name)}-${var.environment}"

  lz_tags = merge(
    { Name = local.lz_prefix, Environment = var.environment, ManagedBy = "Terraform" },
    var.extra_tags
  )

  network_tags = merge(
    { Name = "${local.lz_prefix}-network", Environment = var.environment, ManagedBy = "Terraform" },
    var.extra_tags
  )
}

# =============================================================================
# azurerm.lz resources — landing zone subscription
# =============================================================================

data "azurerm_client_config" "lz" {
  provider = azurerm.lz
}

resource "azurerm_resource_group" "lz" {
  provider = azurerm.lz

  name     = "${local.lz_prefix}-rg"
  location = var.lz_location
  tags     = local.lz_tags
}

resource "azurerm_key_vault" "lz" {
  provider = azurerm.lz

  name                       = "${local.lz_prefix}-kv"
  location                   = azurerm_resource_group.lz.location
  resource_group_name        = azurerm_resource_group.lz.name
  tenant_id                  = data.azurerm_client_config.lz.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = local.lz_tags
}

resource "azurerm_key_vault_access_policy" "deployer" {
  provider = azurerm.lz

  key_vault_id = azurerm_key_vault.lz.id
  tenant_id    = data.azurerm_client_config.lz.tenant_id
  object_id    = data.azurerm_client_config.lz.object_id

  secret_permissions = ["Get", "Set", "List", "Delete"]
}

resource "azurerm_key_vault_secret" "environment" {
  provider = azurerm.lz

  name         = "environment"
  value        = var.environment
  key_vault_id = azurerm_key_vault.lz.id
  tags         = local.lz_tags

  depends_on = [azurerm_key_vault_access_policy.deployer]
}

resource "azurerm_key_vault_secret" "lz_name" {
  provider = azurerm.lz

  name         = "lz-name"
  value        = var.lz_name
  key_vault_id = azurerm_key_vault.lz.id
  tags         = local.lz_tags

  depends_on = [azurerm_key_vault_access_policy.deployer]
}

resource "azurerm_key_vault_secret" "subscription_id" {
  provider = azurerm.lz

  name         = "subscription-id"
  value        = var.lz_subscription_id
  key_vault_id = azurerm_key_vault.lz.id
  tags         = local.lz_tags

  depends_on = [azurerm_key_vault_access_policy.deployer]
}

# =============================================================================
# azurerm.network resources — shared network subscription
# =============================================================================

resource "azurerm_resource_group" "network" {
  provider = azurerm.network

  name     = "${local.lz_prefix}-network-rg"
  location = var.network_location
  tags     = local.network_tags
}

resource "azurerm_key_vault_secret" "network_rg_id" {
  provider = azurerm.lz

  name         = "network-resource-group-id"
  value        = azurerm_resource_group.network.id
  key_vault_id = azurerm_key_vault.lz.id
  tags         = local.lz_tags

  depends_on = [azurerm_key_vault_access_policy.deployer]
}
