# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "rancher2" {
  api_url   = "https://${var.rancher_address}/"
  insecure  = true
  bootstrap = length(var.rancher_version) > 0
  token_key = length(var.rancher_version) > 0 ? null : var.rancher_token
}

module "cluster-support" {
  source = ".\\modules\\cluster-support"

  name                 = var.cluster_name
  resource_location    = var.resource_location

  vnet_address_space   = var.vnet_address_space
  gateway_subnet_cidr  = var.gateway_subnet_cidr
  firewall_subnet_cidr = var.firewall_subnet_cidr
  dmz_subnet_cidr      = var.dmz_subnet_cidr
  bastion_subnet_cidr  = var.bastion_subnet_cidr
  shared01_subnet_cidr = var.shared01_subnet_cidr
  enable_bastion       = var.enable_bastion
}

module "cluster" {
  source = ".\\modules\\rke2-cluster"

  depends_on = [ module.cluster-support ]

  name                      = var.cluster_name
  resource_location         = var.resource_location

  rancher_address           = var.rancher_address
  letsencrypt_email_address = var.letsencrypt_email_address

  vnet_id     = module.cluster-support.cluster_vnet_id
  vnet_name   = module.cluster-support.cluster_vnet_name
  subnet_id   = module.cluster-support.cluster_dmz_subnet_id
  subnet_name = module.cluster-support.cluster_dmz_subnet_name

  enable_server_public_ip  = var.enable_server_public_ip
  enable_server_public_ssh = var.enable_server_public_ssh

  agent_vm_size  = var.agent_vm_size
  server_vm_size = var.server_vm_size

  server_instance_count = var.server_instance_count
  agent_instance_count  = var.agent_instance_count

  rke2_version    = var.rke2_version
  rancher_version = var.rancher_version

  register_cluster = var.register_cluster
}
