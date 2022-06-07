# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

variable "name" {
  description   = "Load balancer name"
  type = string
}

variable "resource_group_name" {
  description = "Name of the resource group where to store the load balancer"
  type = string
}

variable "type" {
  description = "Toggle between private or public load balancer"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.type)
    error_message = "Allowed values for type are \"public\" or \"private\"."
  }
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "private_ip_address" {
  type    = string
  default = null
}

variable "private_ip_address_allocation" {
  type    = string
  default = null
}
