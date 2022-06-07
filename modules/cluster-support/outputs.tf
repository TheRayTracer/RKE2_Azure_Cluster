# File: outputs.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

output "cluster_vnet_id" {
  value = azurerm_virtual_network.cluster_vnet.id
}

output "cluster_vnet_name" {
  value = azurerm_virtual_network.cluster_vnet.name
}

output "cluster_dmz_subnet_id" {
  value = azurerm_subnet.cluster_dmz_subnet.id
}

output "cluster_dmz_subnet_name" {
  value = azurerm_subnet.cluster_dmz_subnet.name
}
