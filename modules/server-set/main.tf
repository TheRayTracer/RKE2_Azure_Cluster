# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_linux_virtual_machine_scale_set" "scale" {
  name = "${var.name}-vmss"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku                             = var.vm_size
  instances                       = var.instances
  overprovision                   = var.overprovision
  zones                           = var.zones
  zone_balance                    = var.zone_balance
  upgrade_mode                    = "Automatic"
  priority                        = "Regular"
  health_probe_id                 = var.health_probe_id
  disable_password_authentication = true

  custom_data = var.custom_data

  admin_username = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_id = var.source_image_id

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      offer     = lookup(var.source_image_reference, "offer")
      publisher = lookup(var.source_image_reference, "publisher")
      sku       = lookup(var.source_image_reference, "sku")
      version   = lookup(var.source_image_reference, "version")
    }
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = var.os_disk_storage_account_type
    disk_encryption_set_id = null # Investigate using this.
    disk_size_gb           = var.os_disk_size_gb
  }

  dynamic "data_disk" {
    for_each = var.additional_data_disks
    content {
      lun                  = lookup(data_disk, "lun")
      disk_size_gb         = lookup(data_disk, "disk_size_gb", 80)
      caching              = lookup(data_disk, "caching", "ReadWrite")
      storage_account_type = lookup(data_disk, "storage_account_type", "Standard_LRS")
    }
  }

  network_interface {
    name                          = "${var.name}-ssvm-nic"
    primary                       = true
    network_security_group_id     = var.nsg_id
    dns_servers                   = []
    enable_accelerated_networking = false

    ip_configuration {
      name      = "${var.name}-ssvm-ipconfig"
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids = var.load_balancer_backend_address_pool_ids
      load_balancer_inbound_nat_rules_ids    = var.load_balancer_inbound_nat_rules_ids

      dynamic "public_ip_address" {
        for_each = var.assign_public_ips ? [{}] : []
        content {
          name = "${var.name}-ssvm-pip"
        }
      }
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = var.identity_ids
  }

  automatic_instance_repair {
    enabled      = false
    grace_period = null
  }
}