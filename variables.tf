# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

############
# Cluster details
############

variable "cluster_name" {
  type        = string
  description = "Name to identify Kubernetes cluster"
}

variable "resource_location" {
  type        = string
  description = "Azure location to store the cluster resources"
}

variable "rancher_address" {
  type        = string
  description = "Full domain of the Rancher server"
}

variable "letsencrypt_email_address" {
  type        = string
  description = "Email address to use for the letsencrypt certificate service"
}

variable "register_cluster" {
  description = "Flag to register a new cluster with an exisiting Rancher at the above domain"
  type        = bool
  default     = false
}

variable "rancher_token" {
  description = "Manually fetch the token value from: https:/<rancher-url>/v3-public/localProviders/local?action=login"
  type        = string
}

variable "rke2_version" {
  type        = string
  description = "RKE2 version to use"
}

variable "rancher_version" {
  type        = string
  description = "Rancher version to use"
}

############
# Cluster size
############

variable "server_vm_size" {
  type        = string
  description = "VM size to use for the server (control planes) nodes"
  default     = "Standard_B4ms"
}

variable "agent_vm_size" {
  type        = string
  description = "VM size to use for the agent (worker) nodes"
  default     = "Standard_B4ms"
}

variable "server_instance_count" {
  description = "Number of server (control plane) nodes to deploy"
  type        = number
  default     = 1
}

variable "agent_instance_count" {
  description = "Number of agent (worker) nodes to deploy"
  type        = number
  default     = 1
}

############
# Cluster Network
############

variable "vnet_address_space" {
  description = "Vnet CIDR block"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "gateway_subnet_cidr" {
  description   = "Gateway subnet CIDR"
  type          = list(string)
  default       = ["10.1.255.224/27"]
}

variable "firewall_subnet_cidr" {
  description   = "Firewall subnet CIDR"
  type          = list(string)
  default       = ["10.1.255.192/27"]
}

variable "dmz_subnet_cidr" {
  description   = "DMZ subnet CIDR"
  type          = list(string)
  default       = ["10.1.254.0/24"]
}

variable "bastion_subnet_cidr" {
  description   = "Bastion subnet CIDR"
  type          = list(string)
  default       = [ "10.1.253.0/26"]
}

variable "shared01_subnet_cidr" {
  description   = "shared01 subnet CIDR"
  type          = list(string)
  default       = ["10.1.0.0/24"]
}

variable "enable_bastion" {
  description = "Place a bastion into the cluster VNet"
  type        = bool
  default     = true
}

variable "enable_server_public_ip" {
  description = "Assign a public IP to the control plane load balancer"
  type        = bool
}

variable "enable_server_public_ssh" {
  description = "Allow SSH to the server nodes through the control plane load balancer"
  type        = bool
  default     = false
}
