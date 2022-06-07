# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

variable "name" {
  type        = string
  description = "Name to identify the cluster"
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

variable "rke2_version" {
  type        = string
  description = "RKE2 version to download"
}

variable "rancher_version" {
  type        = string
  description = "Rancher version to use"
}

variable "register_cluster" {
  type        = bool
  description = "Toggle to register the cluster with existing Rancher instance"
}

variable "vnet_id" {
  description = "Id of the virtual network where to deploy the cluster"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network where to deploy the cluster"
  type        = string
}

variable "subnet_id" {
  description = "Id of the subnet where to deploy the cluster"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet where to deploy the cluster"
  type        = string
}

variable "server_vm_size" {
  type        = string
  description = "VM size to use for the server nodes"
  default     = "Standard_B4ms"
}

variable "agent_vm_size" {
  type        = string
  description = "VM size to use for the agent nodes"
  default     = "Standard_B4ms"
}

variable "server_instance_count" {
  description = "Number of server nodes to deploy"
  type        = number
  default     = 1
}

variable "agent_instance_count" {
  description = "Number of agent nodes to deploy"
  type        = number
  default     = 2
}

variable "enable_server_public_ip" {
  description = "Assign public IPs to control plane nodes in the cluster"
  type        = bool
}

variable "enable_server_public_ssh" {
  description = "Allow SSH access to control plane nodes in the cluster"
  type        = bool
}
