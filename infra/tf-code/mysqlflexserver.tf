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

variable "vnet_id" {
  type        = string
  description = "VNET ID"
}

variable "subnet_id" {
  type        = string
  description = "Dedicated SBNET ID"
}

variable "key_vault_id" {
  type        = string
  description = "KeyVault to store credentials"
}


resource "azurerm_private_dns_zone" "this" {
  name                = "[__mysql_dns_name__]"
  resource_group_name = var.resource_group_name
}


resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "[__mysql_server_name__]"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_mysql_flexible_server" "this" {
  name                   = "[__mysql_server_name__]"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = "mysqladmin"
  administrator_password = "asf!SD123l"
  backup_retention_days  = 2
  sku_name               = "B_Standard_B1s"
  zone                   = "1"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]
}

resource "azurerm_mysql_flexible_database" "this" {
  name                = "[__mysql_db_name__]"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


resource "azurerm_mysql_flexible_server_firewall_rule" "this" {
  name                = "FirewallRule1"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  start_ip_address    = "[__my_ip__]"
  end_ip_address      = "[__my_ip__]"
}

# Allow access to Azure services)
resource "azurerm_mysql_flexible_server_firewall_rule" "azure" {
  name                = "FirewallRule2"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Save admin login into keyvault
resource "azurerm_key_vault_secret" "login" {
  name         = "${azurerm_mysql_flexible_server.this.name}-admin-login"
  value        = azurerm_mysql_flexible_server.this.administrator_login
  key_vault_id = var.key_vault_id
}

# Save admin password into keyvault
resource "azurerm_key_vault_secret" "password" {
  name         = "${azurerm_mysql_flexible_server.this.name}-admin-password"
  value        = azurerm_mysql_flexible_server.this.administrator_password
  key_vault_id = var.key_vault_id
}
