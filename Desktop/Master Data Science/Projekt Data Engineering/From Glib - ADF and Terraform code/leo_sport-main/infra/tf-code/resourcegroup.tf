terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.112.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
  }
}

provider "azurerm" {
  features {}
}


variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
  default = {}
}

resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups
  location = each.value["location"]
  name     = each.value["name"]
  tags     = lookup(each.value, "tags", {})

}

output "resource_group_ids" {
  value       = { for r in azurerm_resource_group.this : r.name => r.id }
  description = "Map of RG groups"
}