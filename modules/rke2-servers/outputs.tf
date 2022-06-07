# File: outputs.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

output "ip_address" {
  value = module.external-load-balancer.ip_address
}

output "token" {
  value = random_password.token.result
}

output "vault_id" {
  value = module.vault.vault_id
}

output "cluster_identity" {
  value = azurerm_user_assigned_identity.cluster.name
}