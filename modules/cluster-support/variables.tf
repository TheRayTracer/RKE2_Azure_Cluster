# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

variable "name" {
  type        = string
  description = "Name to identify the Kubernetes cluster"
}

variable "resource_location" {
  type        = string
  description = "Azure location to store the cluster resources"
}

variable "vnet_address_space" {
  description = "VNet CIDR block e.g. 10.0.0.0/16"
  type        = list(string)
}

variable "gateway_subnet_cidr" {
  description   = "Gateway subnet CIDR e.g. 10.0.255.224/27"
  type          = list(string)
}

variable "firewall_subnet_cidr" {
  description   = "Firewall subnet CIDR e.g. 10.0.255.192/27"
  type          = list(string)
}

variable "dmz_subnet_cidr" {
  description   = "DMZ subnet CIDR e.g. 10.0.254.0/24"
  type          = list(string)
}

variable "bastion_subnet_cidr" {
  description   = "Bastion subnet CIDR e.g. 10.0.253.0/26"
  type          = list(string)
}

variable "shared01_subnet_cidr" {
  description   = "shared01 subnet CIDR e.g. 10.0.0.0/24"
  type          = list(string)
}

variable "enable_bastion" {
  description = "Flag to place a bastion into the cluster VNet"
  type        = bool
  default     = true
}
