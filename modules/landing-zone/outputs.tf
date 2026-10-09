output "resource_group_name" {
  description = "The name of the landing zone resource group"
  value       = azurerm_resource_group.lz.name
}

output "key_vault_id" {
  description = "The resource ID of the landing zone Key Vault"
  value       = azurerm_key_vault.lz.id
}

output "key_vault_name" {
  description = "The name of the landing zone Key Vault"
  value       = azurerm_key_vault.lz.name
}
