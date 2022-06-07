# File: variables.tfvars; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

cluster_name = "rancher-cluster"

rancher_address = "rancher.mydomain.com"

resource_location = "australiaeast"

enable_server_public_ip = true

rke2_version = "v1.21.12+rke2r2"

rancher_version = "2.6.3"

letsencrypt_email_address = "hello@email.com"

server_instance_count = 3

register_cluster = false

rancher_token = null