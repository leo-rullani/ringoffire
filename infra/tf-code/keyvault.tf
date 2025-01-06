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

data "azurerm_client_config" "current" {}

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

variable "keyvaults" {
  type = map(object(
    {
      name = string
      access_policy = list(object({
        object_id           = string
        key_permissions     = list(string)
        secret_permissions  = list(string)
        storage_permissions = list(string)
      }))
    }
  ))
  description = "List of SNETs and their deligation"
}

resource "azurerm_key_vault" "this" {
  for_each                    = var.keyvaults
  name                        = each.value["name"]
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  dynamic "access_policy" {
    for_each = coalesce(lookup(each.value, "access_policy"), [])
    content {
      tenant_id           = data.azurerm_client_config.current.tenant_id
      object_id           = lookup(access_policy.value, "object_id", null)
      key_permissions     = lookup(access_policy.value, "key_permissions", null)
      secret_permissions  = lookup(access_policy.value, "secret_permissions", null)
      storage_permissions = lookup(access_policy.value, "storage_permissions", null)
    }
  }
}