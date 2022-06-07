# File: outputs.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

output "scale_set_id" {
  value = azurerm_linux_virtual_machine_scale_set.scale.id
}