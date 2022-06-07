# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

# This module is a giant ball of unrelated files.
# This module should be split out into seperate file rendering modules in the near future.

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "template_file" "download" {
  template = file("${path.module}/files/rke2-download.sh")
  vars = {
    type         = var.type
    rke2_version = var.rke2_version
  }
}

data "template_file" "setup" {
  template = file("${path.module}/files/rke2-setup.sh")

  vars = {
    type        = var.type
    ip_address  = var.ip_address
    token       = var.token
    node_labels = var.node_labels
    node_taints = var.node_taints

    registration_command = var.registration_command

    pre_install  = data.template_file.pre.rendered
    post_install = length(var.rancher_version) > 0 ? data.template_file.rancher.rendered : ""
  }
}

data "template_file" "vm" {
  template = file("${path.module}/files/vm-map-count.conf")
}

data "template_file" "pre" {
  template = file("${path.module}/files/rke2-pre.sh")
}

data "template_file" "rancher" {
  template = file("${path.module}/files/rke2-rancher.sh")
  vars = {
    rancher_address = var.rancher_address
    rancher_version = var.rancher_version
    letsencrypt_email_address = var.letsencrypt_email_address
  }
}

data "template_file" "cloud" {
  template = file("${path.module}/files/azure-cloud.conf.template")
  vars = {
    tenant_id                 = data.azurerm_client_config.current.tenant_id
    subscription_id           = data.azurerm_client_config.current.subscription_id
    user_assigned_identity_id = var.user_assigned_identity_id
    rg_name                   = data.azurerm_resource_group.rg.name
    location                  = data.azurerm_resource_group.rg.location
    subnet_name               = var.subnet_name
    virtual_network_name      = var.virtual_network_name
    nsg_name                  = var.nsg_name
  }
}

data "template_file" "storage" {
  template = file("${path.module}/files/default-storageclass.yaml")
}
