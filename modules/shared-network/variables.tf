variable "name" {
  description = "Shared network hub name, used as a prefix for all resources (e.g. \"shared-network-hub\")"
  type        = string
}

variable "location" {
  description = "Azure region for the shared network resources"
  type        = string
}

variable "extra_tags" {
  description = "Additional tags to merge into all resources — useful for demonstrating in-place updates during a live demo"
  type        = map(string)
  default     = {}
}
