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

variable "role_definitions" {
  description = "Map of role parameters"
  type = map(object({
    name              = string
    scope             = string
    description       = string
    actions           = list(string)
    not_actions       = list(string)
    assignable_scopes = list(string)
  }))
  default = {}
}

variable "role_assignments" {
  description = "Map of role assignments parameters"
  type = map(object({
    scope        = string
    role_name    = string
    principal_id = string
  }))
  default = {}
}

variable "delay_after_rbac_creation" {
  type        = string
  description = "delay 10 sec after rbac created"
  default     = "10s"
}


resource "azurerm_role_definition" "this" {
  for_each = var.role_definitions

  name        = each.value["name"]
  scope       = each.value["scope"]
  description = each.value["description"]
  permissions {
    actions     = each.value["actions"]
    not_actions = each.value["not_actions"]
  }
  assignable_scopes = each.value["assignable_scopes"]
}

resource "time_sleep" "delay_after_rbac_creation" {
  depends_on      = [azurerm_role_definition.this]
  create_duration = var.delay_after_rbac_creation
}

