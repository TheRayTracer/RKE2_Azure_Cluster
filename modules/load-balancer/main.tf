# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "pip" {
  count = var.type == "public" ? 1 : 0

  name              = "${var.name}-pip"
  allocation_method = "Static"
  sku               = "Standard"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_lb" "lb" {
  name = "${var.name}-lb"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku = "Standard"

  frontend_ip_configuration {
    name                          = "${var.name}-fe"
    public_ip_address_id          = var.type == "public" ? azurerm_public_ip.pip[0].id : null
    subnet_id                     = var.type == "public" ? null : var.subnet_id
    private_ip_address            = var.private_ip_address
    private_ip_address_allocation = var.private_ip_address_allocation
  }
}

#
# Load Balancer backend address pool
#
resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = "${var.name}-lb-be-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

#
# Load Balancer health probe
#
resource "azurerm_lb_probe" "probe" {
  name                = "${var.name}-lb-probe"
  loadbalancer_id     = azurerm_lb.lb.id

  protocol            = "Tcp"
  interval_in_seconds = 10
  number_of_probes    = 3

  port = 6443
}

resource "azurerm_lb_rule" "controlplane" {
  name                = "${var.name}-lb-rule-cp"
  loadbalancer_id     = azurerm_lb.lb.id

  protocol      = "Tcp"
  frontend_port = 6443
  backend_port  = 6443

  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration.0.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.probe.id
}

resource "azurerm_lb_rule" "supervisor" {
  name                = "${var.name}-lb-rule-supervisor"
  loadbalancer_id     = azurerm_lb.lb.id

  protocol      = "Tcp"
  backend_port  = 9345
  frontend_port = 9345

  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration.0.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.probe.id
}

resource "azurerm_lb_rule" "http" {
  name                = "${var.name}-lb-rule-http"
  loadbalancer_id     = azurerm_lb.lb.id

  protocol      = "Tcp"
  backend_port  = 80
  frontend_port = 80

  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration.0.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.probe.id
}

resource "azurerm_lb_rule" "https" {
  name                = "${var.name}-lb-rule-https"
  loadbalancer_id     = azurerm_lb.lb.id

  protocol      = "Tcp"
  backend_port  = 443
  frontend_port = 443

  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration.0.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.probe.id
}

resource "azurerm_lb_nat_pool" "ssh" {
  name                           = "SSHNatPool"
  loadbalancer_id                = azurerm_lb.lb.id
  resource_group_name            = data.azurerm_resource_group.rg.name

  protocol                       = "Tcp"
  frontend_port_start            = 5000
  frontend_port_end              = 5100
  backend_port                   = 22

  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
}
