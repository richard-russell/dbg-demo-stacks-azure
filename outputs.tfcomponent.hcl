output "lz_resource_group_names" {
  type        = map(string)
  description = "Resource group names for each landing zone, keyed by LZ identifier"
  value       = { for k, _ in var.lz_configs : k => component.landing_zone[k].resource_group_name }
}

output "lz_key_vault_names" {
  type        = map(string)
  description = "Key Vault names for each landing zone, keyed by LZ identifier"
  value       = { for k, _ in var.lz_configs : k => component.landing_zone[k].key_vault_name }
}

output "shared_network_resource_group_name" {
  type        = string
  description = "Resource group name for the shared network hub"
  value       = component.shared_network.resource_group_name
}
