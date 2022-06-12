# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

locals {
  uname = lower("${random_string.uid1.result}${random_string.uid2.result}") # Must start with a letter!
}

resource "random_string" "uid1" {
  length  = 2
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "random_string" "uid2" {
  length  = 6
  special = false
  lower   = true
  upper   = false
  numeric = true
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "random_password" "token" {
  length  = 40
  special = false
}

module "vault" {
  source = "..\\key-vault"

  name                = "${local.uname}-kv"
  resource_group_name = data.azurerm_resource_group.rg.name

  token            = random_password.token.result
  reader_object_id = azurerm_user_assigned_identity.cluster.principal_id
}

resource "azurerm_user_assigned_identity" "cluster" {
  name = "${local.uname}-mi"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "cluster_vault" {
  scope                = data.azurerm_resource_group.rg.id
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
  role_definition_name = "Key Vault Secrets User"
}

resource "azurerm_role_assignment" "cluster_reader" {
  scope                = module.servers.scale_set_id
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "role1" {
  scope                            = data.azurerm_resource_group.rg.id
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_user_assigned_identity.cluster.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "role2" {
  scope                            = data.azurerm_resource_group.rg.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.cluster.principal_id
  skip_service_principal_aad_check = true
}

#
# Server Network Security Group
#
resource "azurerm_network_security_group" "server" {
  name = "server-nsg"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_network_security_rule" "cluster_ingress_ssh" {
  name                        = "cluster_ingress_ssh"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.server.name
}

resource "azurerm_network_security_rule" "cluster_ingress_http" {
  name                        = "cluster_ingress_http"
  priority                    = 210
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.server.name
}

resource "azurerm_network_security_rule" "cluster_ingress_health_check" {
  name                        = "cluster_ingress_health_check"
  priority                    = 220
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.server.name
}

resource "azurerm_network_security_rule" "cluster_ingress_health_check_cp_port" {
  name                        = "cluster_ingress_health_check_cp_port"
  priority                    = 230
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.server.name
}

resource "azurerm_network_security_rule" "node_connection_port" {
  name                        = "node_connection_port"
  priority                    = 240
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9345"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.server.name
}

resource "azurerm_network_security_rule" "cluster_ingress_https" {
  name                        = "cluster_ingress_https"
  priority                    = 250
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.server.name
}

resource "azurerm_network_security_rule" "cluster_metrics" {
  name                        = "cluster_metrics"
  priority                    = 260
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.server.name
}

module "server_files" {
  source = "..\\data"

  resource_group_name = var.resource_group_name

  ip_address = module.external-load-balancer.ip_address
  token      = random_password.token.result

  registration_command = var.registration_command

  rke2_version = var.rke2_version
  type         = "server"

  rancher_version = var.rancher_version

  rancher_address = var.rancher_address

  letsencrypt_email_address = var.letsencrypt_email_address

  subnet_name               = var.subnet_name
  virtual_network_name      = var.virtual_network_name
  nsg_name                  = var.k8s_nsg_name
  user_assigned_identity_id = azurerm_user_assigned_identity.cluster.client_id
}

data "template_cloudinit_config" "init" {
  part {
    filename     = "download.sh"
    content_type = "text/x-shellscript"
    content      = module.server_files.download
  }

  part {
    filename     = "setup.sh"
    content_type = "text/x-shellscript"
    content      = module.server_files.setup
  }

  part {
    filename     = "azure-cloud.tpl"
    content_type = "text/cloud-config"
    content = jsonencode({
      write_files = [
        {
          content     = module.server_files.vm
          path        = "/etc/sysctl.d/10-vm-map-count.conf"
          permissions = "5555"
        },
        {
          content     = module.server_files.cloud
          path        = "/etc/rancher/rke2/cloud.conf"
          permissions = "5555"
        },
        {
          content     = module.server_files.storage
          path        = "/var/lib/rancher/rke2/server/manifests/default-storageclass.yaml"
          permissions = "5555"
        }
      ]
    })
  }
}

module "external-load-balancer" {
  source = "..\\load-balancer"

  name = "server-set"
  resource_group_name = data.azurerm_resource_group.rg.name

  subnet_id                     = var.subnet_id
  private_ip_address            = var.controlplane_loadbalancer_private_ip_address
  private_ip_address_allocation = var.controlplane_loadbalancer_private_ip_address_allocation

  type = var.enable_public_ip ? "public" : "private"
}

module "servers" {
  source = "..\\server-set"

  name = "server-set"

  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_id  = var.virtual_network_id
  subnet_id           = var.subnet_id

  admin_ssh_public_key = var.admin_ssh_public_key

  vm_size   = var.vm_size
  instances = var.instances
  overprovision = false # Setting this to false, as the RKE2 bootstrap setup script relies on well ordered hostnames to elect a leader
  zones         = var.zones
  zone_balance  = var.zone_balance

  source_image_reference = var.source_image_reference
  assign_public_ips      = var.assign_public_ips
  nsg_id                 = azurerm_network_security_group.server.id

  health_probe_id                        = module.external-load-balancer.controlplane_probe_id
  load_balancer_backend_address_pool_ids = [module.external-load-balancer.backend_pool_id]
  load_balancer_inbound_nat_rules_ids    = var.enable_public_ssh ? [module.external-load-balancer.azurerm_lb_nat_pool_ssh_id] : []

  identity_ids = [azurerm_user_assigned_identity.cluster.id]
  custom_data  = data.template_cloudinit_config.init.rendered

  os_disk_size_gb              = var.os_disk_size_gb
  os_disk_storage_account_type = var.os_disk_storage_account_type

  additional_data_disks = var.additional_data_disks

  depends_on = [module.external-load-balancer]
}