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

variable "key_vault_id" {
  type        = string
  description = "KeyVault to store credentials"
}



resource "azurerm_mssql_server" "this" {
  name                         = "[__mssql_server_name__]"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "mssqladmin"
  administrator_login_password = "asf!SD123l"
}

resource "azurerm_mssql_database" "example" {
  name                        = "[__mssql_db_name__]"
  server_id                   = azurerm_mssql_server.this.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = 4
  read_scale                  = false
  sku_name                    = "GP_S_Gen5_1"
  zone_redundant              = false
  enclave_type                = "Default"
  min_capacity                = 1
  auto_pause_delay_in_minutes = 60

  tags = var.tags

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

# Save admin login into keyvault
resource "azurerm_key_vault_secret" "login" {
  name         = "${azurerm_mssql_server.this.name}-admin-login"
  value        = azurerm_mssql_server.this.administrator_login
  key_vault_id = var.key_vault_id
}

# Save admin password into keyvault
resource "azurerm_key_vault_secret" "password" {
  name         = "${azurerm_mssql_server.this.name}-admin-password"
  value        = azurerm_mssql_server.this.administrator_login_password
  key_vault_id = var.key_vault_id
}


resource "azurerm_mssql_firewall_rule" "this" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "[__my_ip__]"
  end_ip_address   = "[__my_ip__]"
}


resource "azurerm_mssql_firewall_rule" "azure" {
  name             = "FirewallRule2"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}