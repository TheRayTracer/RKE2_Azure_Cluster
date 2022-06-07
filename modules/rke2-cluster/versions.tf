# File: versions.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.95.0"
    }

    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.22.2"
    }
  }
}