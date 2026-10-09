variable "network_resource_group_name" {
  description = "Name of the shared network hub resource group"
  type        = string
}

variable "network_resource_group_id" {
  description = "Resource ID of the shared network hub resource group (tagged onto LZ resources via azurerm.lz, and used to tag the network hub via azurerm.network)"
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the landing zone Key Vault (written via azurerm.lz)"
  type        = string
}

variable "extra_tags" {
  description = "Additional tags merged into all resources"
  type        = map(string)
  default     = {}
}
