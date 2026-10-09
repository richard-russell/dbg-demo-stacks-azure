output "lz_resource_group_name" {
  description = "Name of the landing zone resource group"
  value       = azurerm_resource_group.lz.name
}

output "lz_key_vault_name" {
  description = "Name of the landing zone Key Vault"
  value       = azurerm_key_vault.lz.name
}

output "lz_key_vault_id" {
  description = "Resource ID of the landing zone Key Vault"
  value       = azurerm_key_vault.lz.id
}

output "network_resource_group_name" {
  description = "Name of the shared network resource group"
  value       = azurerm_resource_group.network.name
}
