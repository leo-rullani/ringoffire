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

variable "resource_group_name" {
  type    = string
  default = null
}

variable "location" {
  type    = string
  default = null
}

variable "tags" {
  type        = map(any)
  description = "Tags for Storage accuont"
}


variable "private_dns_zones" {
  type = map(object(
    {
      dns_zone_name = string
    }
  ))
  description = "DNS Zone Name"
}

variable "private_dns_zone_links" {
  type = map(object(
    {
      name         = string
      dns_zone_key = string
      vnet_id      = string
    }
  ))
  description = "DNS Zone Name"
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = var.private_dns_zones
  name                = each.value["dns_zone_name"]
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.private_dns_zone_links

  name                  = each.value["name"]
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.dns_zone_key].name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = each.value["vnet_id"]
}
