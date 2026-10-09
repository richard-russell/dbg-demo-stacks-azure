variable "identity_token_lz" {
  type        = string
  description = "OIDC JWT for the per-LZ azurerm provider instances"
  ephemeral   = true
}

variable "identity_token_network" {
  type        = string
  description = "OIDC JWT for the shared azurerm.network provider"
  ephemeral   = true
}

variable "identity_token_azuread" {
  type        = string
  description = "OIDC JWT for the azuread provider"
  ephemeral   = true
}

variable "lz_configs" {
  type = map(object({
    subscription_id = string
    client_id       = string
    location        = string
  }))
  description = "Map of landing zone configurations keyed by LZ identifier (e.g. lz_01)"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, test, prod)"
  default     = "dev"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID shared across all provider instances"
}

variable "network_subscription_id" {
  type        = string
  description = "Subscription ID for the shared network provider"
}

variable "network_client_id" {
  type        = string
  description = "Client ID of the shared network app registration"
}

variable "network_location" {
  type        = string
  description = "Azure region for shared network resources"
  default     = "uksouth"
}

variable "azuread_client_id" {
  type        = string
  description = "Client ID of the Azure AD app registration"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags merged into all resources"
  default     = {}
}
