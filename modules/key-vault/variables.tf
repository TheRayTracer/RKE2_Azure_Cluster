# File: variables.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

variable "name" {
  type        = string
  description = "The name of the key vault"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "token" {
  type        = string
  description = "The token value"
}

variable "reader_object_id" {
  type        = string
  description = "The object ID"
}
