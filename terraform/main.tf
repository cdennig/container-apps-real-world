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
  value        = module.data.module.data.sqldb_connectionstring
  key_vault_id = module.common.keyvault_id
}

# # Data

# output "search_primary_key_base64" {
#   value = base64encode(module.data.search_primary_key)
#   sensitive = true
# }

# output "search_name_base64" {
#   value = base64encode(module.data.search_name)
#   sensitive = true
# }

# output "textanalytics_endpoint_base64" {
#   value = base64encode(module.data.textanalytics_endpoint)
#   sensitive = true
# }

# output "textanalytics_key_base64" {
#   value = base64encode(module.data.textanalytics_key)
#   sensitive = true
# }

# # Storage

# output "resources_primary_connection_string_base64" {
#   value = base64encode(module.storage.resources_primary_connection_string)
#   sensitive = true
# }

# output "funcs_primary_connection_string_base64" {
#   value = base64encode(module.storage.funcs_primary_connection_string)
#   sensitive = true
# }

# # Messaging

# output "thumbnail_listen_connectionstring_base64" {
#   value = base64encode(module.messaging.thumbnail_listen_connectionstring)
#   sensitive = true
# }

# output "thumbnail_send_connectionstring_base64" {
#   value = base64encode(module.messaging.thumbnail_send_connectionstring)
#   sensitive = true
# }

# output "contacts_listen_connectionstring_base64" {
#   value = base64encode(module.messaging.contacts_listen_connectionstring)
#   sensitive = true
# }

# output "contacts_listen_with_entity_connectionstring_base64" {
#   value = base64encode(module.messaging.contacts_listen_with_entity_connectionstring)
#   sensitive = true
# }

# output "contacts_send_connectionstring_base64" {
#   value = base64encode(module.messaging.contacts_send_connectionstring)
#   sensitive = true
# }

# output "visitreports_listen_connectionstring_base64" {
#   value = base64encode(module.messaging.visitreports_listen_connectionstring)
#   sensitive = true
# }

# output "visitreports_send_connectionstring_base64" {
#   value = base64encode(module.messaging.visitreports_send_connectionstring)
#   sensitive = true
# }
