# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

locals {
  registration_command = var.register_cluster ? rancher2_cluster.rke2[0].cluster_registration_token[0].insecure_command : ""
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.resource_location
}

resource "rancher2_cluster" "rke2" {
  count = var.register_cluster ? 1 : 0
  name  = var.name

  rke2_config {
    upgrade_strategy {
      drain_server_nodes = true
      drain_worker_nodes = true
    }
  }
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_network_security_group" "k8s_nsg" {
  name = "k8s-nsg"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "servers" {
  source = "..\\rke2-servers"

  resource_group_name  = azurerm_resource_group.rg.name

  registration_command = local.registration_command

  subnet_id            = var.subnet_id
  subnet_name          = var.subnet_name
  virtual_network_id   = var.vnet_id
  virtual_network_name = var.vnet_name
  k8s_nsg_name         = azurerm_network_security_group.k8s_nsg.name

  admin_ssh_public_key = tls_private_key.default.public_key_openssh

  rancher_address  = var.rancher_address
  letsencrypt_email_address = var.letsencrypt_email_address

  instances = var.server_instance_count
  vm_size   = var.server_vm_size

  rke2_version    = var.rke2_version
  rancher_version = var.rancher_version

  enable_public_ip  = var.enable_server_public_ip
  enable_public_ssh = var.enable_server_public_ssh
}

module "agents" {
  source = "..\\rke2-agents"

  resource_group_name = azurerm_resource_group.rg.name

  subnet_id            = var.subnet_id
  subnet_name          = var.subnet_name
  virtual_network_id   = var.vnet_id
  virtual_network_name = var.vnet_name
  k8s_nsg_name         = azurerm_network_security_group.k8s_nsg.name

  admin_ssh_public_key = tls_private_key.default.public_key_openssh

  rancher_address = var.rancher_address

  instances = var.agent_instance_count
  vm_size   = var.agent_vm_size

  rke2_version = var.rke2_version

  cluster_identity = module.servers.cluster_identity

  token = module.servers.token
  ip_address = module.servers.ip_address
}

resource "azurerm_key_vault_secret" "node_key" {
  name         = "node-key"
  value        = tls_private_key.default.private_key_pem
  key_vault_id = module.servers.vault_id

  depends_on = [module.servers]
}

resource "local_file" "node_private_key" {
  content  = tls_private_key.default.private_key_pem
  filename = ".ssh/rk2_id_rsa"
}

resource "local_file" "node_public_key" {
  content  = tls_private_key.default.public_key_openssh
  filename = ".ssh/rk2_id_rsa.pub"
}
