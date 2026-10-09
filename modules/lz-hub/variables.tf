variable "lz_name" {
  description = "Landing zone identifier used as a resource name prefix (e.g. lz-01)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "lz_location" {
  description = "Azure region for landing zone resources"
  type        = string
  default     = "uksouth"
}

variable "lz_subscription_id" {
  description = "Azure subscription ID for this landing zone (stored as a Key Vault secret)"
  type        = string
}

variable "network_location" {
  description = "Azure region for shared network resources"
  type        = string
  default     = "uksouth"
}

variable "extra_tags" {
  description = "Additional tags merged into all resources"
  type        = map(string)
  default     = {}
}
