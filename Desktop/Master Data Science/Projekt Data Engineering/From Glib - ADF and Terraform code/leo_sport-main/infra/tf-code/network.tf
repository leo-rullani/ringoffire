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


# Network variables
variable "resource_group_name" {
  type        = string
  description = "Name of the resource grou"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used the virtual network. You can supply more than one address space."
}

variable "vnet_name" {
  type        = string
  description = "VNET name"
}

variable "nsg_name" {
  type        = string
  description = "NSG name"
}

variable "subnets" {
  type = map(object(
    {
      name             = string
      address_prefixes = list(string)
      delegation = list(object({
        name = string
        service_delegation = list(object({
          name    = string
          actions = list(string)
        }))
      }))
    }
  ))
  description = "List of SNETs and their delegation"
}



resource "azurerm_network_security_group" "this" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}


resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.value["name"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value["address_prefixes"]

  dynamic "delegation" {
    for_each = coalesce(lookup(each.value, "delegation"), [])
    content {
      name = lookup(delegation.value, "name", null)
      dynamic "service_delegation" {
        for_each = coalesce(lookup(delegation.value, "service_delegation"), [])
        content {
          name    = lookup(service_delegation.value, "name", null)
          actions = lookup(service_delegation.value, "actions", null)
        }

      }
    }

  }

  #   delegation {
  #     name = "delegation"

  #     service_delegation {
  #       name    = "Microsoft.ContainerInstance/containerGroups"
  #       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #     }
  #   }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this.id
}