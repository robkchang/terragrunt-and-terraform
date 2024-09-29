# When hcl files are included, they execute in the folder/context of the level of the terragrunt.hcl
# Anything in this file can be executed in any environment, at any folder depth
locals {
    # The folder terragrunt.hcl is in our resource folder (always)
    resource_folder = basename(get_terragrunt_dir())

    # Wherever this file is, that is our resource group name (this may also be a team or project name)
    resource_group = basename(dirname(find_in_parent_folders("resource_group_include.hcl")))

    # Wherever this file is, that is our subscription (this may also be the deployment environment e.g. Prod, Staging, etc)
    environment = basename(dirname(find_in_parent_folders("environment_include.hcl")))

    # Prefixes for resources
    prefix_long = lower("${local.environment}-${local.resource_group}-")
    prefix_long_no_dash = lower("${local.environment}${local.resource_group}")
    prefix_short = lower("${local.environment}-${substr(local.resource_group,-3,-1)}-")
    # ^^^ substr("string",-X, -1) will give the last X characters until the end of the line (-1)
    # So, this might look like qa001, if the sub folders are named something like Team001
}

# Generate a backend (on per project)
generate "backend" {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
terraform {
    backend "azurerm" {
        resource_group_name  = "terraform-shared"
        storage_account_name = "${local.environment}somethingunique"
        container_name = "${local.environment}-tfstate"
        key = "${local.resource_group}-${local.resource_folder}.tfstate"
    }
}
EOF
}

inputs = {
    resource_group_name = local.resource_group
    subscription_name = local.environment
    environment = local.environment
    tags = {
        Subscription = local.environment
        Company = "Company name"
    }
}