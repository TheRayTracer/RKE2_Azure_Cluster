# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to put the server cluster on"
}

variable "rancher_address" {
  type        = string
  description = "The full domain of Rancher server"
}

variable "letsencrypt_email_address" {
  type        = string
  description = "Email address to use for the letsencrypt certificate service"
}

variable "rke2_version" {
  type        = string
  description = "RKE2 version to use"
}

variable "rancher_version" {
  type        = string
  description = "Rancher version to use"
}

variable "registration_command" {
  type = string
  description = "Rancher Server Registration command for the RKE2 cluster"
}

variable "virtual_network_id" {
  type        = string
  description = "Id of the virtual network to put the server cluster on"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the virtual network to put the server cluster on"
}

variable "subnet_id" {
  type        = string
  description = "Id of the subnet to put the server cluster on"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet to put the server cluster on"
}

variable "k8s_nsg_name" {
  type        = string
  description = "Name of the NSG to add to the server cluster"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key of the admin user of the server cluster"
  default     = ""
}

variable "assign_public_ips" {
  type        = string
  description = "If true assign public IPs to nodes in the cluster"
  default     = false
}

variable "instances" {
  description = "Number of servers to create"
  type        = number
  default     = 1
}

variable "controlplane_loadbalancer_type" {
  description = "Type of load balancer to use for the control plane"
  type        = string
  default     = "private"
}

variable "controlplane_loadbalancer_private_ip_address" {
  description = "IP address of the private load balancer for the control plane"
  type        = string
  default     = null
}

variable "controlplane_loadbalancer_private_ip_address_allocation" {
  description = "IP address allocation of the private load balancer for the control plane"
  type        = string
  default     = null
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
    sku       = "7-LVM"
    version   = "latest"
  }
}

variable "vm_size" {
  type        = string
  default     = "Standard_B4ms"
  description = "Server set vm size"
}

variable "zones" {
  description = "List of availability zones servers should be created in."
  type        = list(number)
  default     = []
}

variable "zone_balance" {
  description = "Toggle server balance within availability zones specified."
  type        = string
  default     = null
}

variable "os_disk_storage_account_type" {
  description = "Storage Account used for OS Disk. Possible values include Standard_LRS or Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_size_gb" {
  description = "Storage disk size for OS in GB. Defaults to 64Gb."
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

variable "enable_public_ip" {
  description = "Assign public IPs to control plane nodes in the cluster"
  type        = bool
}

variable "enable_public_ssh" {
  description = "Allow ssh access to control plane nodes in the cluster"
  type        = bool
}
