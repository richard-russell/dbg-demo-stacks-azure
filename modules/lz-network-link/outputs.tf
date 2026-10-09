output "network_hub_resource_group_id" {
  description = "Resource ID of the shared network hub resource group, as read by azurerm.network"
  value       = data.azurerm_resource_group.network_hub.id
}

output "network_hub_secret_id" {
  description = "Resource ID of the Key Vault secret storing the network hub resource group ID"
  value       = azurerm_key_vault_secret.network_hub_id.id
}
