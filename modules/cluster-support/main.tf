# File: main.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

# Create a VNet with multiple subnets. Each subnet is configured with a security group to be associated with the subnet.
# When using Azure gateway subnet, never deploy any VMs or other devices, such as Azure Application Gateway, to the gateway subnet.
# Don't assign a network security group (NSG) to GatewaySubnet subnet. Otherwise it will cause the gateway to stop functioning.
#

resource "azurerm_resource_group" "vnet_rg" {
  name     = "${var.name}-vnet-rg"
  location = var.resource_location
}

resource "azurerm_network_security_group" "vnet_nsg" {
    name                = "${var.name}-vnet-nsg"
    resource_group_name = azurerm_resource_group.vnet_rg.name
    location            = azurerm_resource_group.vnet_rg.location
}

/*
resource "azurerm_network_security_rule" "cluster_egress_all" {
  name                        = "cluster_egress_all"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.vnet_rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg.name
}
*/

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
  resource_group_name         = azurerm_resource_group.vnet_rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg.name
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
  resource_group_name         = azurerm_resource_group.vnet_rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg.name
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
  resource_group_name         = azurerm_resource_group.vnet_rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg.name
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
  resource_group_name         = azurerm_resource_group.vnet_rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg.name
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
  resource_group_name         = azurerm_resource_group.vnet_rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg.name
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
  resource_group_name         = azurerm_resource_group.vnet_rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg.name
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
  resource_group_name         = azurerm_resource_group.vnet_rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg.name
}

# Create virtual network
resource "azurerm_virtual_network" "cluster_vnet" {
    name                = "${var.name}-vnet"
    resource_group_name = azurerm_resource_group.vnet_rg.name
    location            = azurerm_resource_group.vnet_rg.location
    address_space       = var.vnet_address_space
}

# Create VNet Public IP
resource "azurerm_public_ip" "cluster_vnet_ip" {
  name                = "${var.name}-vnet-ip"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location            = azurerm_resource_group.vnet_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create gateway subnet
# Do not assign a network security group (NSG) to GatewaySubnet subnet
resource "azurerm_subnet" "cluster_gateway_subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.vnet_rg.name
    virtual_network_name = azurerm_virtual_network.cluster_vnet.name
    address_prefixes     = var.gateway_subnet_cidr
}

# Create Azure firewall subnet
resource "azurerm_subnet" "cluster_firewall_subnet" {
    name                 = "AzureFirewallSubnet"
    resource_group_name  = azurerm_resource_group.vnet_rg.name
    virtual_network_name = azurerm_virtual_network.cluster_vnet.name
    address_prefixes     = var.firewall_subnet_cidr
}

# Create DMZ subnet
resource "azurerm_subnet" "cluster_dmz_subnet" {
    name                 = "${var.name}-cluster-dmz-subnet"
    resource_group_name  = azurerm_resource_group.vnet_rg.name
    virtual_network_name = azurerm_virtual_network.cluster_vnet.name
    address_prefixes     = var.dmz_subnet_cidr
}

# Create bastion subnet
resource "azurerm_subnet" "cluster_bastion_subnet" {
    count                = var.enable_bastion == true ? 1 : 0
    name                 = "AzureBastionSubnet"
    resource_group_name  = azurerm_resource_group.vnet_rg.name
    virtual_network_name = azurerm_virtual_network.cluster_vnet.name
    address_prefixes     = var.bastion_subnet_cidr
}

# Create shared01 subnet
resource "azurerm_subnet" "cluster_shared01_subnet" {
    name                 = "${var.name}-cluster-shared01-subnet"
    resource_group_name  = azurerm_resource_group.vnet_rg.name
    virtual_network_name = azurerm_virtual_network.cluster_vnet.name
    address_prefixes     = var.shared01_subnet_cidr
}

resource "azurerm_subnet_network_security_group_association" "cluster_shared01_secgroup_association" {
  subnet_id                   = azurerm_subnet.cluster_shared01_subnet.id
  network_security_group_id   = azurerm_network_security_group.vnet_nsg.id
}

# Create Bastion Host
resource "azurerm_bastion_host" "bastion_host" {
  count                = var.enable_bastion ? 1 : 0
  name                = "bastion-host"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location            = azurerm_resource_group.vnet_rg.location

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.cluster_bastion_subnet[0].id
    public_ip_address_id = azurerm_public_ip.cluster_vnet_ip.id
  }
}

# Create NAT Gateway Public IP
resource "azurerm_public_ip" "nat_gw_pip" {
  name                = "nat-gw-pip"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location            = azurerm_resource_group.vnet_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create NAT Gateway
resource "azurerm_nat_gateway" "nat_gw" {
  name                = "nat-gw"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location            = azurerm_resource_group.vnet_rg.location
  sku_name            = "Standard"
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_gw_pip_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw.id
  public_ip_address_id = azurerm_public_ip.nat_gw_pip.id
}

# Associate NAT Gateway with DMZ subnet
resource "azurerm_subnet_nat_gateway_association" "nat_gw_subnet_association" {
  subnet_id      = azurerm_subnet.cluster_dmz_subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}