# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_key_vault" "vault" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_template_deployment = true
}

resource "azurerm_key_vault_access_policy" "policy" {
  key_vault_id = azurerm_key_vault.vault.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  key_permissions = []
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}

resource "azurerm_key_vault_access_policy" "service_reader" {
  key_vault_id = azurerm_key_vault.vault.id
  object_id    = var.reader_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  key_permissions         = []
  secret_permissions      = ["Get", "Set"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_key_vault_secret" "token" {
  name         = "join-token"
  key_vault_id = azurerm_key_vault.vault.id
  value        = var.token

  depends_on = [azurerm_key_vault_access_policy.policy]
}
