# Include inputs that go to every enviroment and resource group
include "global_include" {
    path = find_in_parent_folders("global_include.hcl")
    expose = true
}

# Include inputs that go to every resource group in an environment
include "environment_include" {
    path = find_in_parent_folders("environment_include.hcl")
    expose = true
}

# Include inputs that go to every resource within a resource group
include "resource_group_include" {
    path = find_in_parent_folders("resource_group_include.hcl")
    expose = true
}

locals {
    extra_tags = {
        "ResponsibleTeam" = include.resource_group_include.locals.responsible_team
        "Contact" = "R Chang"
    }

    # This module may rely on other modules, copy them into our Terragrunt cache
    # We do a lookup, since 
    modulesPath = "\"${dirname(find_in_parent_folders("environment_include"))}/modules"
}

# Dependencies that need to be executed with this in a terragrunt run-all
dependencies {
    paths = ["../my-first-resource-group"]
}

# So, this is in here, but it isn't necessary since we don't use the outputs. But, this is how we would get
# outputs from other modules
dependency "resource_group" {
    config_path = "../my-first-resource-group"
    skip_outputs = true
}

terraform {
    source = "${path_relative_from_include("environment_include")}/modules/level1/my-first-level2-networkmodule"
}

inputs = {
    # Where are the other inputs for this module?  Inherited!
    extra_tags = local.extra_tags
}