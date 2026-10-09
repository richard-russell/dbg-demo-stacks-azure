output "resource_group_name" {
  description = "The name of the shared network hub resource group"
  value       = azurerm_resource_group.network.name
}

output "resource_group_id" {
  description = "The resource ID of the shared network hub resource group"
  value       = azurerm_resource_group.network.id
}
