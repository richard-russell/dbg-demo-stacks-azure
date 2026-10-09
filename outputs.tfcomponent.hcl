output "lz_resource_group_name" {
  type        = string
  description = "Resource group name for this landing zone"
  value       = component.lz_hub.lz_resource_group_name
}

output "lz_key_vault_name" {
  type        = string
  description = "Key Vault name for this landing zone"
  value       = component.lz_hub.lz_key_vault_name
}

output "network_resource_group_name" {
  type        = string
  description = "Resource group name for the shared network hub"
  value       = component.lz_hub.network_resource_group_name
}
