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
    # This will rely on a module that calls other modules in our modules folder. Take note of how
    # this module references level1 modules.  Level1 modules don't have dependencies on other modules
    # Level2 modules rely on Level1 modules.
    source = "${path_relative_from_include("environment_include")}/modules/level1/my-first-level2-networkmodule"
    before_hook "copy_modules" {
        commands = ["init", "plan", "apply"]
        # Copy all modules to a modules folder, so L1 references are much easier to use. We won't have to
        # play games with ../../../ sourcing. We can just find where the root folder should be and copy
        # the modules over. Notice, in the copy-item command that the destination is . (right here)
        # in the context this is executing, it will be in the .terragrunt-cache folder.  Right where we
        # want it to land!
        execute = ["powershell.exe", "-Command", "Copy-Item ${local.modulesPath} . -Recurse -Force"]
    }
}

inputs = {
    vnet_address_space      = ["10.0.0.0/16"]
    subnets = {
        gateway_subnet      = ["10.0.0.0/27"]
        container_subnet    = ["10.0.0.32/27"]
        endpoints_subnet    = ["10.0.2.0/24"]
        app_gw_subnet       = ["10.0.3.0/24"]
        vmss_subnet         = ["10.0.4.0/24"]
        static_sites_subnet = ["10.0.5.0/24"]
    }
    private_dns_zones = [
        "blob", "file", "table", "queue", "keyvault",
        "sqlserver", "registry", "staticSites",
        "staticSites_partition1", "staticSites_partition2",
        "staticSites_partition3", "staticSites_partition4",
        "staticSites_partition5", "staticSites_partition6"
    ]
    # Where are the other inputs for this module?  Inherited!
    extra_tags = local.extra_tags
}