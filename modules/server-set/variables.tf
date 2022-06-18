# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "name" {
  type        = string
  description = "Prefix server set name"
}

variable "admin_username" {
  type        = string
  description = "Admin username to use for the server set machines"
  default     = "rke2"
}

variable "virtual_network_id" {
  type        = string
  description = "Virtual network id where to deploy the server set"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id where to deploy the server set"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key to use for the server set"
}

variable "assign_public_ips" {
  type        = bool
  description = "Flag to assign public ips to nodes"
}

variable "load_balancer_backend_address_pool_ids" {
  default     = []
  description = "List of backend address pool ids to use for the load balancer"
  type        = list(string)
}

variable "load_balancer_inbound_nat_rules_ids" {
  default     = []
  description = "List of inbound nat rules ids to use for the load balancer"
  type        = list(string)
}

variable "health_probe_id" {
  type        = string
  description = "The health probe id to use for the server set"
  default     = null
}

variable "instances" {
  type        = number
  description = "The number of nodes to create in the server set"
  default     = 1
}

variable "nsg_id" {
  type        = string
  description = "The network security group id to use for the server set"
}

variable "vm_size" {
  type        = string
  description = "The vm size to use for the server set"
}

variable "identity_ids" {
  type        = list(string)
  description = "List of identities to assign to the server set"
}

variable "additional_data_disks" {
  type = list(object({
    lun                  = number
    disk_size_gb         = number
    caching              = string
    storage_account_type = string
  }))
  description = "List of additional data disks to attach to the server set"
}

variable "custom_data" {
  type        = string
  description = "Init script to run on each node"
}

variable "source_image_id" {
  description = "ID of an image to use for each VM in the scale set"
  default     = null
}

variable "source_image_reference" {
  description = "Source image query parameters"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "The storage account type to use for the server set"
}

variable "os_disk_size_gb" {
  type        = number
  description = "The size of the OS disk in GB"
}

variable "overprovision" {
  default     = false
  type        = bool
  description = "Flag to overprovision the server set"
}

variable "zones" {
  type        = list(string)
  description = "List of availability zones to deploy the server set to"
}

variable "zone_balance" {
  type        = bool
  description = "Flag to balance the server set across availability zones"
}
