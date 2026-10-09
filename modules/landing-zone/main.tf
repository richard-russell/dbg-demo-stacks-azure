terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.lz]
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

locals {
  common_tags = merge(
    {
      Name        = lower(var.name)
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.extra_tags
  )
}

# -----------------------------------------------------------------------------
# Client config: read tenant ID and deployer object ID from the LZ provider
# -----------------------------------------------------------------------------

data "azurerm_client_config" "lz" {
  provider = azurerm.lz
}

# -----------------------------------------------------------------------------
# Resource Group: Landing Zone
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "lz" {
  provider = azurerm.lz

  name     = "${lower(var.name)}-rg"
  location = var.location

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Key Vault: Landing Zone secrets store
# -----------------------------------------------------------------------------

resource "azurerm_key_vault" "lz" {
  provider = azurerm.lz

  name                       = "${lower(var.name)}-kv"
  location                   = azurerm_resource_group.lz.location
  resource_group_name        = azurerm_resource_group.lz.name
  tenant_id                  = data.azurerm_client_config.lz.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Key Vault Access Policy: grants the deployer service principal get/set/list
# -----------------------------------------------------------------------------

resource "azurerm_key_vault_access_policy" "deployer" {
  provider = azurerm.lz

  key_vault_id = azurerm_key_vault.lz.id
  tenant_id    = data.azurerm_client_config.lz.tenant_id
  object_id    = data.azurerm_client_config.lz.object_id

  secret_permissions = ["Get", "Set", "List", "Delete"]
}

# -----------------------------------------------------------------------------
# Key Vault Secrets: environment and name
# -----------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "environment" {
  provider = azurerm.lz

  name         = "environment"
  value        = var.environment
  key_vault_id = azurerm_key_vault.lz.id

  tags = local.common_tags

  depends_on = [azurerm_key_vault_access_policy.deployer]
}

resource "azurerm_key_vault_secret" "name" {
  provider = azurerm.lz

  name         = "name"
  value        = var.name
  key_vault_id = azurerm_key_vault.lz.id

  tags = local.common_tags

  depends_on = [azurerm_key_vault_access_policy.deployer]
}
