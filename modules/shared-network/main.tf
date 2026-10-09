terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.network]
    }
  }
}

locals {
  common_tags = merge(
    {
      Name      = lower(var.name)
      ManagedBy = "Terraform"
    },
    var.extra_tags
  )
}

# -----------------------------------------------------------------------------
# Resource Group: Shared Network Hub
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "network" {
  provider = azurerm.network

  name     = "${lower(var.name)}-rg"
  location = var.location

  tags = local.common_tags
}
