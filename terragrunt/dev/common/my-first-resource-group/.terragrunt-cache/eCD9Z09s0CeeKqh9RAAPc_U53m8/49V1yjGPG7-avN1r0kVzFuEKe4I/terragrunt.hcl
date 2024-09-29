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
}

terraform {
    source = "${path_relative_from_include("environment_include")}/modules/level1/my-first-level1-module"
}

inputs = {
    # Where are the other inputs for this module?  Inherited!
    extra_tags = local.extra_tags
}