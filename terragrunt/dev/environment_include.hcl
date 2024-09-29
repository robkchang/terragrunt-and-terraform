# This is for environment specific inputs and files to be created

locals {
    region = "eastus2"
    subId = "1234567-1234-1234-1234-12345678901"
}

generate "providers" {
    path = "providers.tf"
    if_exists = "overwrite"
    contents = <<EOF
terraform {
    required_version = ">= 1.9.6"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 4.3.0, <= 4.3.0"
        }
    }
}

provider "azurerm" {
    subscription_id = "${local.subId}"
    features {
        key_vault {
            purge_soft_delete_on_destroy = true
            recover_soft_deleted_key_vaults = true
        }
    }
}
EOF
}

# Populate "location" for every resource that includes this
inputs = {
    location = local.region
}