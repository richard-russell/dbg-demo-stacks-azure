terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.lz, azurerm.network]
    }
  }
}

# -----------------------------------------------------------------------------
# Stub module — data source removed so the removed {} block in
# components.tfcomponent.hcl can plan without hitting Azure.
# The only resource tracked in state is the Key Vault secret below.
# -----------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "network_hub_id" {
  provider = azurerm.lz

  name         = "network-hub-resource-group-id"
  value        = var.network_resource_group_name
  key_vault_id = var.key_vault_id

  tags = merge({ ManagedBy = "Terraform" }, var.extra_tags)
}
