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

variable "storage_account" {
  type    = string
  default = null
}

variable "storage_containers" {
  type = map(object(
    {
      name                  = string
      container_access_type = string
    }
  ))
  description = "(optional) describe your variable"
}

variable "ip_rules" {
  type    = list(string)
  default = null
}

variable "key_vault_id" {
  type        = string
  description = "KeyVault IDs to store the key"
  default     = null
}

resource "azurerm_storage_account" "this" {
  name                          = var.storage_account
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  access_tier                   = "Cool"
  public_network_access_enabled = true
  is_hns_enabled                = true

  network_rules {
    default_action = "Deny"
    ip_rules       = var.ip_rules
  }


  tags = var.tags
}

# Wait to apply network rules
resource "time_sleep" "wait_30_seconds" {
  depends_on      = [azurerm_storage_account.this]
  create_duration = "30s"
}

# Save Blob Access Key into keyvault
resource "azurerm_key_vault_secret" "this" {
  name         = "${azurerm_storage_account.this.name}-access-key"
  value        = azurerm_storage_account.this.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_storage_container" "this" {
  for_each              = var.storage_containers
  name                  = each.value["name"]
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value["container_access_type"]
}
