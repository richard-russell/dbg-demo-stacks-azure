output "lz_resource_group_name" {
  type        = string
  description = "Resource group name for this landing zone"
  value       = component.landing_zone.resource_group_name
}

output "lz_key_vault_name" {
  type        = string
  description = "Key Vault name for this landing zone"
  value       = component.landing_zone.key_vault_name
}

output "shared_network_resource_group_name" {
  type        = string
  description = "Resource group name for the shared network hub"
  value       = component.shared_network.resource_group_name
}
