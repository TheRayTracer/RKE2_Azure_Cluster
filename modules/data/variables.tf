# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

variable "resource_group_name" {
  description = "Name of the resource group where the vm scale set resides"
  type        = string
}

variable "ip_address" {
  description = "RKE2 IP address"
  type        = string
}

variable "token" {
  description = "Cluster join token value"
  type        = string
}

variable "rke2_version" {
  description = "Version of RKE2 to download and use"
  type        = string
}

variable "rancher_version" {
  description = "Version of rancher to pass to helm to download for installation"
  type        = string
}

variable "type" {
  description = "agent or server"
  type        = string
  validation {
    condition     = contains(["agent", "server"], var.type)
    error_message = "Allowed values for type are \"agent\" or \"server\"."
  }
}

variable "registration_command" {
  description = "Rancher Server Registration command for the RKE2 cluster"
  type        = string
}

variable "node_labels" {
  description = "Node labels to add to the cluster"
  type        = string
  default     = "[]"
}

variable "node_taints" {
  description = "Node taints to add to the cluster"
  type        = string
  default     = "[]"
}

variable "rancher_address" {
  type        = string
  description = "Full domain of the Rancher server"
}

variable "letsencrypt_email_address" {
  type        = string
  description = "Email address to use for the letsencrypt certificate service"
}

variable "subnet_name" {
  type        = string
  description = "The subnet name"
}

variable "virtual_network_name" {
  type        = string
  description = "The virtual network name"
}

variable "nsg_name" {
  type        = string
  description = "The NSG name"
}

variable "user_assigned_identity_id" {
  type        = string
  description = "The user identity from a managed identity"
}
