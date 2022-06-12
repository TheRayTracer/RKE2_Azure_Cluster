# File: versions.tf; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.22.2"
    }
  }
}
