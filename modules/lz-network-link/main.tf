terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.lz, azurerm.network]
    }
  }
}

# -----------------------------------------------------------------------------
# Read the shared network hub resource group via azurerm.network
# Demonstrates azurerm.network provider in use within this module
# -----------------------------------------------------------------------------

data "azurerm_resource_group" "network_hub" {
  provider = azurerm.network

  name = var.network_resource_group_name
}

# -----------------------------------------------------------------------------
# Write a Key Vault secret in the LZ Key Vault recording the network hub details
# Demonstrates azurerm.lz provider in use within the same module
# -----------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "network_hub_id" {
  provider = azurerm.lz

  name         = "network-hub-resource-group-id"
  value        = data.azurerm_resource_group.network_hub.id
  key_vault_id = var.key_vault_id

  tags = merge({ ManagedBy = "Terraform" }, var.extra_tags)
}
