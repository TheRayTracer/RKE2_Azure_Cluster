# File: outputs.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

output "download" {
  value = data.template_file.download.rendered
}

output "vm" {
  value = data.template_file.vm.rendered
}

output "setup" {
  value = data.template_file.setup.rendered
}

output "cloud" {
  value = data.template_file.cloud.rendered
}

output "storage" {
  value = data.template_file.storage.rendered
}
