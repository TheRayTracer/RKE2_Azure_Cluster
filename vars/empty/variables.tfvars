# File: variables.tfvars; Mode: Terraform; Tab-width: 2; Author: Simon Flannery;

cluster_name = "app-cluster"

rancher_address = "rancher.mydomain.com"

resource_location = "australiaeast"

enable_server_public_ip = false

rke2_version = "v1.21.12+rke2r2"

rancher_version = "" # Do not install Rancher

letsencrypt_email_address = "hello@email.com"

register_cluster = true # Register using the token below

rancher_token = "token-mk8wp:w2tcgltvrmzh9ql55zfkgghnw5rpdccpdz48sgjqwjrnpg2vj9m8vl"