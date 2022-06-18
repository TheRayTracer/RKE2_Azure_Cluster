# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "rancher_address" {
  type        = string
  description = "The full domain of Rancher server"
}

variable "rke2_version" {
  type        = string
  description = "RKE2 version to use"
}

variable "virtual_network_id" {
  type        = string
  description = "Identity of the virtual network where to deploy the agents"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the virtual network where to deploy the agents"
}

variable "subnet_id" {
  type        = string
  description = "Identity of the subnet where to deploy the agents"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet where to deploy the agents"
}

variable "k8s_nsg_name" {
  type        = string
  description = "Name of the kubernets nsg where to deploy the agents"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "The SSH public key to use for SSH access to the agents"
  default     = ""
}

variable "assign_public_ips" {
  type        = bool
  description = "If true, the nodes will be assigned public IPs"
  default     = false
}

variable "instances" {
  description = "Number of agents to create"
  type        = number
  default     = 1
}

variable "cluster_identity" {
  type        = string
  description = "The managed identity"
}

variable "token" {
  type        = string
  description = "The token value to join a cluster"
}

variable "ip_address" {
  type        = string
  description = "The IP address of the rancher server"
}

#
# Server set variables
#
variable "source_image_reference" {
  description = "Source image query parameters"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

  default = {
    offer     = "RHEL"
    publisher = "RedHat"
    sku       = "8-LVM"
    version   = "latest"
  }
}

variable "vm_size" {
  type        = string
  description = "Server pool vm size"
  default     = "Standard_B4ms"
}

variable "zones" {
  description = "List of availability zones where agents should be created"
  type        = list(number)
  default     = []
}

variable "zone_balance" {
  description = "Toggle server balance within availability zones specified"
  default     = null
}

variable "os_disk_storage_account_type" {
  description = "Storage Account used for OS Disk - possible values include Standard_LRS or Premium_LRS"
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_size_gb" {
  description = "Storage disk size for OS in GB - defaults to 64Gb"
  type        = number
  default     = 64
}

variable "additional_data_disks" {
  type = list(object({
    lun                  = number
    disk_size_gb         = number
    caching              = string
    storage_account_type = string
  }))
  default = []
}
