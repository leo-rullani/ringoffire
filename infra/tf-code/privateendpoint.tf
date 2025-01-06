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


variable "private_endpoints" {
  type = map(object(
    {
      name                           = string
      subnet_id                      = string
      private_connection_resource_id = string
      groups_ids                     = list(string)
      approval_require               = bool
      approval_message               = string
      dns_zone_names                 = list(string)
      dns_zone_group_name            = string
      private_dns_zone_ids           = list(string)
    }
  ))
  description = "PE configuratio"
}

variable "approval_message" {
  type        = string
  description = "Message to approve PE"
  default     = "Please approve my pe request"
}

resource "azurerm_private_endpoint" "this" {
  for_each            = var.private_endpoints
  location            = var.location
  name                = each.value["name"]
  resource_group_name = var.resource_group_name
  subnet_id           = each.value["subnet_id"]
  private_service_connection {
    is_manual_connection           = (coalesce(lookup(each.value, "approval_require"), false) == true)
    name                           = "${each.value["name"]}-connection"
    private_connection_resource_id = each.value["private_connection_resource_id"]
    subresource_names              = lookup(each.value, "groups_ids", null)
    request_message = (coalesce(lookup(each.value, "approval_require"), false) == true
      ? coalesce(lookup(each.value, "approval_message"), var.approval_message)
      : null
    )
  }

  dynamic "private_dns_zone_group" {
    for_each = lookup(each.value, "dns_zone_names", null) != null ? [1] : []
    content {
      name                 = each.value["dns_zone_group_name"]
      private_dns_zone_ids = each.value["private_dns_zone_ids"]
    }
  }

  tags = var.tags

}