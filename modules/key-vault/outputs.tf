# File: outputs.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

output "vault_url" {
  value = azurerm_key_vault.vault.vault_uri
}

output "vault_id" {
  value = azurerm_key_vault.vault.id
}

output "vault_name" {
  value = azurerm_key_vault.vault.name
}
