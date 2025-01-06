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

variable "adf_name" {
  type    = string
  default = null
}

variable "account_name" {
  type    = string
  default = null
}
variable "branch_name" {
  type    = string
  default = null
}
variable "source_control" {
  type    = string
  default = null
}
variable "repository_name" {
  type    = string
  default = null

}

variable "key_vault_id" {
  type        = string
  description = "KeyVault ID"
}

variable "tags" {
  type        = map(any)
  description = "Tags for Storage accuont"
}


data "azurerm_client_config" "current" {}


resource "azurerm_data_factory" "this" {
  name                = var.adf_name
  location            = var.location
  resource_group_name = var.resource_group_name
  github_configuration {
    account_name    = var.account_name
    branch_name     = var.branch_name
    git_url         = var.source_control
    repository_name = var.repository_name
    root_folder     = "/"
  }
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

variable "adf_roles" {
  type = map(object({
    scope = string
    role  = string
  }))
  description = "Role to assign ADF idenity"
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id       = var.key_vault_id
  object_id          = azurerm_data_factory.this.identity.0.principal_id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  key_permissions    = ["Get", "Decrypt", "Encrypt", "UnwrapKey", "Sign", "Verify", "WrapKey"]
  secret_permissions = ["Get", "List"]
}

resource "azurerm_role_assignment" "this" {
  for_each             = var.adf_roles
  principal_id         = azurerm_data_factory.this.identity.0.principal_id
  scope                = each.value["scope"]
  role_definition_name = each.value["role"]
}