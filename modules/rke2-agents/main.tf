# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "cluster" {
  name = var.cluster_identity
  resource_group_name = data.azurerm_resource_group.rg.name
}

module "agent_files" {
  source = "..\\data"

  resource_group_name = var.resource_group_name

  ip_address = var.ip_address
  token      = var.token

  registration_command = ""

  rke2_version = var.rke2_version
  type         = "agent"

  rancher_version = ""

  rancher_address = var.rancher_address

  letsencrypt_email_address = ""

  subnet_name               = var.subnet_name
  virtual_network_name      = var.virtual_network_name
  nsg_name                  = var.k8s_nsg_name
  user_assigned_identity_id = data.azurerm_user_assigned_identity.cluster.client_id

  node_labels = "[\"failure-domain.beta.kubernetes.io/region=${data.azurerm_resource_group.rg.location}\"]"
}

data "template_cloudinit_config" "init" {
  part {
    filename     = "download.sh"
    content_type = "text/x-shellscript"
    content      = module.agent_files.download
  }

  part {
    filename     = "setup.sh"
    content_type = "text/x-shellscript"
    content      = module.agent_files.setup
  }

  part {
    filename     = "azure-cloud.tpl"
    content_type = "text/cloud-config"
    content = jsonencode({
      write_files = [
        {
          content     = module.agent_files.vm
          path        = "/etc/sysctl.d/10-vm-map-count.conf"
          permissions = "5555"
        },
        {
          content = module.agent_files.cloud
          path        = "/etc/rancher/rke2/cloud.conf"
          permissions = "5555"
        }
      ]
    })
  }
}

resource "azurerm_network_security_group" "agent" {
  name = "agent-nsg"

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
  network_security_group_name = azurerm_network_security_group.agent.name
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
  network_security_group_name = azurerm_network_security_group.agent.name
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
  network_security_group_name = azurerm_network_security_group.agent.name
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
  network_security_group_name = azurerm_network_security_group.agent.name
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
  network_security_group_name = azurerm_network_security_group.agent.name
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
  network_security_group_name = azurerm_network_security_group.agent.name
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
  network_security_group_name = azurerm_network_security_group.agent.name
}

module "agents" {
  source = "..\\server-set"

  name = "agent-set"

  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_id  = var.virtual_network_id
  subnet_id           = var.subnet_id

  admin_ssh_public_key = var.admin_ssh_public_key

  vm_size       = var.vm_size
  instances     = var.instances
  overprovision = true # https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-design-overview
  zones         = var.zones
  zone_balance  = var.zone_balance

  source_image_reference = var.source_image_reference
  assign_public_ips      = var.assign_public_ips
  nsg_id                 = azurerm_network_security_group.agent.id

  identity_ids = [data.azurerm_user_assigned_identity.cluster.id]
  custom_data  = data.template_cloudinit_config.init.rendered

  os_disk_size_gb              = var.os_disk_size_gb
  os_disk_storage_account_type = var.os_disk_storage_account_type

  additional_data_disks = var.additional_data_disks
}