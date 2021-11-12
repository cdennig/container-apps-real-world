terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.84.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "containerapp" {
  name     = "rg-${var.prefix}-containerapp"
  location = var.location
  tags = {
    environment = var.env
  }
}

# Modules

module "common" {
  source              = "./common"
  location            = azurerm_resource_group.containerapp.location
  resource_group_name = azurerm_resource_group.containerapp.name
  env                 = var.env
  prefix              = var.prefix
}

module "data" {
  source              = "./data"
  location            = azurerm_resource_group.containerapp.location
  resource_group_name = azurerm_resource_group.containerapp.name
  env                 = var.env
  prefix              = var.prefix
  cosmosdbname        = var.cosmosdbname
  cosmoscontainername = var.cosmoscontainername
  sqldbusername       = var.sqldbusername
  sqldbpassword       = var.sqldbpassword
}

module "storage" {
  source              = "./storage"
  location            = azurerm_resource_group.containerapp.location
  resource_group_name = azurerm_resource_group.containerapp.name
  env                 = var.env
  prefix              = var.prefix
}

module "messaging" {
  source              = "./messaging"
  location            = azurerm_resource_group.containerapp.location
  resource_group_name = azurerm_resource_group.containerapp.name
  env                 = var.env
  prefix              = var.prefix
}

resource "azurerm_key_vault_secret" "ai_key" {
  name         = "APPINSIGHTSKEY"
  value        = module.common.ai_instrumentation_key
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "cosmos_url" {
  name         = "COSMOSURL"
  value        = module.data.cosmos_endpoint
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "cosmos_primarykey" {
  name         = "COSMOSKEY"
  value        = module.data.cosmos_primary_master_key
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "sql_connstring" {
  name         = "SQLCONNSTR"
  value        = module.data.sqldb_connectionstring
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "search_key" {
  name         = "SEARCHKEY"
  value        = module.data.search_primary_key
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "search_name" {
  name         = "SEARCHNAME"
  value        = module.data.search_name
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "textanalytics_endpoint" {
  name         = "TAENDPOINT"
  value        = module.data.textanalytics_endpoint
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "textanalytics_key" {
  name         = "TAKEY"
  value        = module.data.textanalytics_key
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "res_conn" {
  name         = "RESCONNSTR"
  value        = module.storage.resources_primary_connection_string
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "func_conn" {
  name         = "FUNCCONNSTR"
  value        = module.storage.funcs_primary_connection_string
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "thumbnail_listen_connectionstring" {
  name         = "THUMBLISTENCONNSTR"
  value        = module.messaging.thumbnail_listen_connectionstring
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "thumbnail_send_connectionstring" {
  name         = "THUMBSENDCONNSTR"
  value        = module.messaging.thumbnail_send_connectionstring
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "contacts_listen_connectionstring" {
  name         = "CONTACTSLISTENCONNSTR"
  value        = module.messaging.contacts_listen_connectionstring
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "contacts_listen_with_entity_connectionstring" {
  name         = "CONTACTSLISTENWITHENTCONNSTR"
  value        = module.messaging.contacts_listen_with_entity_connectionstring
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "contacts_send_connectionstring" {
  name         = "CONTACTSSENDCONNSTR"
  value        = module.messaging.contacts_send_connectionstring
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "visitreports_listen_connectionstring" {
  name         = "VRLISTENCONNSTR"
  value        = module.messaging.visitreports_listen_connectionstring
  key_vault_id = module.common.keyvault_id
}

resource "azurerm_key_vault_secret" "visitreports_send_connectionstring" {
  name         = "VRSENDCONNSTR"
  value        = module.messaging.visitreports_send_connectionstring
  key_vault_id = module.common.keyvault_id
}
