output "network_hub_secret_id" {
  description = "Resource ID of the Key Vault secret storing the network hub resource group ID"
  value       = azurerm_key_vault_secret.network_hub_id.id
}
