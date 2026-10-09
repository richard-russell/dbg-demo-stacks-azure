terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.lz, azurerm.network]
    }
  }
}

# -----------------------------------------------------------------------------
# azurerm.network: tag the shared network hub RG with the LZ name
# Demonstrates a write operation via azurerm.network in this module
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "network_hub_tag" {
  provider = azurerm.network

  name     = var.network_resource_group_name
  location = "uksouth"

  tags = merge(
    { ManagedBy = "Terraform", LinkedLandingZone = var.network_resource_group_name },
    var.extra_tags
  )

  lifecycle {
    # The network hub RG is owned by the shared_network component;
    # here we only manage its tags without taking over the resource.
    ignore_changes = [location]
  }
}

# -----------------------------------------------------------------------------
# azurerm.lz: store the network hub resource group ID in the LZ Key Vault
# Demonstrates a write operation via azurerm.lz in the same module
# -----------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "network_hub_id" {
  provider = azurerm.lz

  name         = "network-hub-resource-group-id"
  value        = var.network_resource_group_id
  key_vault_id = var.key_vault_id

  tags = merge({ ManagedBy = "Terraform" }, var.extra_tags)
}
