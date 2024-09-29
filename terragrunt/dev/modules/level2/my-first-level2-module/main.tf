# Vnet 
module "env_vnet" {
  source = "./modules/level1/my-second-level1-module"

  name                = join("-", [var.subscription_name, var.resource_group_name, "vnet"])
  vnet_address_space  = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags       = var.tags
  extra_tags = var.extra_tags
}

#Subnet and NSG for Gateway (p2S)
locals {
  gtw_nsg_rules_in_csv = <<-CSV

name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes

CSV

  gateway_nsg_rules = csvdecode(local.gtw_nsg_rules_in_csv)

}

module "subnet_gateway" {
  source = "./modules/level1/my-third-level1-module"

  #subnet values
  subnet_name                       = "GatewaySubnet"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = var.address_spaces.gateway_subnet
  service_endpoints                 = []
  subnet_not_have_private_endpoints = true
  subnet_not_have_private_services  = true
  enable_subnet_delegation          = false
  enable_nsg                        = false

  #NSG rules values
  nsg_rules = local.gateway_nsg_rules

  tags       = var.tags
  extra_tags = var.extra_tags

}

#Subnet and NSG for Containers/ACI
locals {
  aci_nsg_rules_in_csv = <<-CSV

name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes

CSV

  aci_nsg_rules = csvdecode(local.aci_nsg_rules_in_csv)

}

module "subnet_aci" {
  source = "./modules/level1/my-third-level1-module"

  #subnet values
  subnet_name                       = "azure-container-instance-snet"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = var.address_spaces.container_subnet
  service_endpoints                 = []
  subnet_not_have_private_endpoints = true
  subnet_not_have_private_services  = true
  enable_subnet_delegation          = true
  services_to_delegate              = "Microsoft.ContainerInstance/containerGroups"
  actions                           = ["Microsoft.Network/virtualNetworks/subnets/action"]
  enable_nsg                        = false

  #NSG rules values
  nsg_rules = local.aci_nsg_rules

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [
    module.env_vnet
  ]

}

#Subnet and NSG for app gateway 
locals {
  app_gw_nsg_rules_in_csv = <<-CSV
name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes
AllowGatewayManager,4096,Inbound,Allow,Tcp,*,,65200-65535,GatewayManager,,*,
Allowport80and443,1001,Inbound,Allow,Tcp,*,,"80,443",*,,*,
CSV
  app_gw_nsg_rules        = csvdecode(local.app_gw_nsg_rules_in_csv)
}

module "subnet_app_gw" {
  source = "./modules/level1/my-third-level1-module"
  #subnet values
  subnet_name                       = "app-gateway-snet"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = var.address_spaces.app_gw_subnet
  service_endpoints                 = []
  subnet_not_have_private_endpoints = true
  subnet_not_have_private_services  = true

  enable_subnet_delegation = false
  #services_to_delegate = ""
  #actions = ["Microsoft.Network/virtualNetworks/subnets/action"]

  #NSG rules values
  nsg_rules = local.app_gw_nsg_rules

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [
    module.env_vnet
  ]

}

#Subnet and NSG for Endpoints
locals {
  endpoints_rules_in_csv = <<-CSV

name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes

CSV

  endpoints_nsg_rules = csvdecode(local.endpoints_rules_in_csv)

}
module "subnet_endpoints" {
  source = "./modules/level1/my-third-level1-module"

  #subnet values
  subnet_name                       = "private-endpoint-snet"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = var.address_spaces.endpoints_subnet
  service_endpoints                 = []
  subnet_not_have_private_endpoints = false
  subnet_not_have_private_services  = true
  enable_subnet_delegation          = false
  enable_nsg                        = false
  #NSG rules values
  nsg_rules = local.endpoints_nsg_rules

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [
    module.env_vnet
  ]

}


#Subnet and NSG for ASE
locals {
  ase_rules_in_csv = <<-CSV
name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes
AllowASEInbound,100,Inbound,Allow,Tcp,*,,"454,455",AppServiceManagement,,10.10.0.0/20,
AllowAzureLoadBalancerInbound,140,Inbound,Allow,Tcp,*,16001,,AzureLoadBalancer,,*,
AllowASEInboundAllowASECommunication,150,Inbound,Allow,*,*,*,,VirtualNetwork,,VirtualNetwork,
AllowAllOutbound,100,Outbound,Allow,*,*,*,,*,,*,
CSV
  ase_nsg_rules    = csvdecode(local.ase_rules_in_csv)

  ase_csv = csvdecode(file("ase_subnets.csv"))

}
module "subnet_ase" {
  for_each = { for aseSnet in local.ase_csv : aseSnet.name => aseSnet }
  source   = "./modules/level1/my-third-level1-module"

  #subnet values
  subnet_name                       = each.value.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = [each.value.cidr]
  service_endpoints                 = ["Microsoft.Storage"]
  subnet_not_have_private_endpoints = true
  subnet_not_have_private_services  = true

  enable_subnet_delegation = true
  services_to_delegate     = "Microsoft.Web/hostingEnvironments"
  actions                  = ["Microsoft.Network/virtualNetworks/subnets/action"]

  #NSG rules values
  nsg_rules = local.ase_nsg_rules

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [
    module.env_vnet
  ]

}

#Subnet and NSG for Classic Cloud Services
locals {
  cloud_rules_in_csv = <<-CSV
name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes
AllowClassicWebTraffic,100,Inbound,Allow,Tcp,*,,"80,443",*,,*,
CSV
  cloud_rules        = csvdecode(local.cloud_rules_in_csv)
}
module "subnet_cloud" {
  source = "./modules/level1/my-third-level1-module"

  subnet_name                       = "cloud-snet"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = var.address_spaces.cloud_subnet
  service_endpoints                 = []
  subnet_not_have_private_endpoints = true
  subnet_not_have_private_services  = true

  enable_subnet_delegation = false

  enable_udr = false

  #NSG rules values
  nsg_rules = local.cloud_rules

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [
    module.env_vnet
  ]

}

#Subnet and NSG for Classic Cloud Services for UDR Routing Apps
locals {
  cloud_udr_rules_in_csv = <<-CSV
name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes
CSV
  cloud_udr_rules        = csvdecode(local.cloud_udr_rules_in_csv)
}
module "subnet_cloud_udr" {
  source = "./modules/level1/my-third-level1-module"

  subnet_name                       = "cloud-udr-snet"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = var.address_spaces.cloud_udr_subnet
  service_endpoints                 = []
  subnet_not_have_private_endpoints = true
  subnet_not_have_private_services  = true

  enable_subnet_delegation = false

  enable_udr = true

  udr_routes = var.deploy_firewall == "Yes" ? [
    {
      name                   = "route_to_vnet_internal",
      address_prefix         = "10.0.0.0/16",
      next_hop_type          = "VnetLocal",
      next_hop_in_ip_address = ""
    },
    {
      name           = "route_to_classic_outbound_snet",
      address_prefix = "0.0.0.0/0",
      next_hop_type  = "VirtualAppliance",
      # If we ever create one, put this back and add back in that module
      #next_hop_in_ip_address = module.env_outbound_fw[0].fw_private_ip
      next_hop_in_ip_address = ""
    }
    ] : [
    {
      name                   = "route_to_vnet_internal",
      address_prefix         = "10.0.0.0/16",
      next_hop_type          = "VnetLocal",
      next_hop_in_ip_address = ""
    }
  ]

  #NSG rules values
  nsg_rules = local.cloud_udr_rules

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [
    module.env_vnet
  ]

}

#Subnet and NSG for Cloud Outbound Traffic
locals {
  cloud_outbound_rules_in_csv = <<-CSV
name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes
CSV
  cloud_outbound_rules        = csvdecode(local.cloud_outbound_rules_in_csv)
}
module "subnet_cloud_outbound" {
  source = "./modules/level1/my-third-level1-module"
  #subnet values
  subnet_name                       = "firewall-snet"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = var.address_spaces.cloud_outbound_subnet
  service_endpoints                 = []
  subnet_not_have_private_endpoints = true
  subnet_not_have_private_services  = true
  enable_subnet_delegation          = false

  enable_nsg = false

  #NSG rules values
  nsg_rules = local.cloud_outbound_rules

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [
    module.env_vnet
  ]
}

#Subnet and NSG for vmss
locals {
  vmss_nsg_rules_in_csv = <<-CSV
name,priority,direction,access,protocol,source_port_ranges,destination_port_range,destination_port_ranges,source_address_prefix,source_address_prefixes,destination_address_prefix,destination_address_prefixes
AllowAzuredevops,100,Inbound,Allow,Tcp,*,443,,AzureDevOps,,*,
CSV

  vmss_nsg_rules = csvdecode(local.vmss_nsg_rules_in_csv)

}
module "subnet_vmss" {
  source = "./modules/level1/my-third-level1-module"

  #subnet values
  subnet_name                       = "vmss-snet"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  vnet_name                         = module.env_vnet.vnet_name
  subnet_prefixes                   = var.address_spaces.vmss_subnet
  service_endpoints                 = []
  subnet_not_have_private_endpoints = true
  subnet_not_have_private_services  = true
  enable_subnet_delegation          = false
  enable_nsg                        = true

  #NSG rules values
  nsg_rules = local.vmss_nsg_rules

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [
    module.env_vnet
  ]

}

# gets the required data for storage accounts from hub.tf file
locals {
  link_env_vnet = [
    { link_vnet_id   = module.env_vnet.vnet_id,
      link_vnet_name = module.env_vnet.vnet_name
    }
  ]
}
# module to create private dns zones
module "private_dns_zones" {
  source              = "./modules/level1/my-fourth-level1-module"
  for_each            = toset(var.private_dns_zones)
  resource_type       = each.value
  resource_group_name = var.resource_group_name
  link_vnet           = local.link_env_vnet

  tags       = var.tags
  extra_tags = var.extra_tags

}

# dns_forwarder container instance
module "dns_forwarder" {
  source = "./modules/level1/my-fifth-level1-module"

  name                = join("-", [var.subscription_name, var.resource_group_name])
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Private"
  subnet_id           = module.subnet_aci.subnet_id
  os_type             = "Linux"
  restart_policy      = "Always"
  container_name      = "dnsforwarder"
  image               = "ghcr.io/whiteducksoftware/az-dns-forwarder/az-dns-forwarder:latest"
  cpu                 = "0.5"
  memory              = "1.5"
  port                = 53
  protocol            = "UDP"

  tags       = var.tags
  extra_tags = var.extra_tags
}
