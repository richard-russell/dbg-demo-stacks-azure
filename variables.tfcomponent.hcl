variable "identity_token" {
  type        = string
  description = "OIDC JWT issued by HCP Terraform — shared across all Azure provider instances (same audience)"
  ephemeral   = true
}

variable "lz_name" {
  type        = string
  description = "Landing zone identifier used as a resource name prefix (e.g. lz-01)"
}

variable "lz_subscription_id" {
  type        = string
  description = "Azure subscription ID for this landing zone"
}

variable "lz_client_id" {
  type        = string
  description = "Client ID of the app registration for this landing zone"
}

variable "lz_location" {
  type        = string
  description = "Azure region for landing zone resources"
  default     = "uksouth"
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
