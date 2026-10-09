variable "name" {
  description = "Landing zone name, used as a prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for this landing zone"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID for this landing zone (used for naming and stored as a Key Vault secret)"
  type        = string
}

variable "extra_tags" {
  description = "Additional tags to merge into all resources — useful for demonstrating in-place updates during a live demo"
  type        = map(string)
  default     = {}
}
