terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.lz, azurerm.network]
    }
  }
}

# -----------------------------------------------------------------------------
# azurerm.network: look up the shared network hub RG that was created by the
# shared_network component. Because network_resource_group_name is an output of
# component.shared_network, Stacks guarantees that component has already applied
# before this component runs — so the data source will always resolve.
# -----------------------------------------------------------------------------

data "azurerm_resource_group" "network_hub" {
  provider = azurerm.network

  name = var.network_resource_group_name
}

# -----------------------------------------------------------------------------
# azurerm.lz: store the network hub resource group ID in the LZ Key Vault.
# Demonstrates both providers active in a single module — azurerm.network reads,
# azurerm.lz writes — mirroring the customer's multi-provider module pattern.
# -----------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "network_hub_id" {
  provider = azurerm.lz

  name         = "network-hub-resource-group-id"
  value        = data.azurerm_resource_group.network_hub.id
  key_vault_id = var.key_vault_id

  tags = merge({ ManagedBy = "Terraform" }, var.extra_tags)
}
