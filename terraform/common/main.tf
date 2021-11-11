data "azurerm_client_config" "current" {
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.prefix}ai${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  retention_in_days   = 90
  tags = {
    environment = var.env
    source      = "AzureDevCollege"
  }
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "kv-${var.prefix}scm${var.env}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get","Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"
    ]
  }
}

output "ai_instrumentation_key" {
  value       = azurerm_application_insights.appinsights.instrumentation_key
  description = "Application Insights Instrumentation Key"
}

output "keyvault_id" {
  value       = azurerm_key_vault.keyvault.id
  description = "KeyVaultId"
}
