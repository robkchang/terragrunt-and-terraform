locals {

  dns_zone_name = {
    keyvault               = "privatelink.vaultcore.azure.net"
    blob                   = "privatelink.blob.core.windows.net"
    table                  = "privatelink.table.core.windows.net"
    queue                  = "privatelink.queue.core.windows.net"
    file                   = "privatelink.file.core.windows.net"
    web                    = "privatelink.web.core.windows.net"
    datalake               = "privatelink.dfs.core.windows.net"
    sqlserver              = "privatelink.database.windows.net"
    staticsites            = "privatelink.azurestaticapps.net"
    staticsites_partition1 = "privatelink.1.azurestaticapps.net"
    staticsites_partition2 = "privatelink.2.azurestaticapps.net"
    staticsites_partition3 = "privatelink.3.azurestaticapps.net"
    staticsites_partition4 = "privatelink.4.azurestaticapps.net"
    staticsites_partition5 = "privatelink.5.azurestaticapps.net"
    staticsites_partition6 = "privatelink.6.azurestaticapps.net"
    registry               = "privatelink.azurecr.io"
    none                   = "none"
  }

  pvt_subresource = {
    keyvault               = "vault"
    blob                   = "blob"
    table                  = "table"
    queue                  = "queue"
    file                   = "file"
    web                    = "web"
    datalake               = "dfs"
    sqlserver              = "sqlServer"
    staticsites            = "staticSites"
    staticsites_partition1 = "staticSites"
    staticsites_partition2 = "staticSites"
    staticsites_partition3 = "staticSites"
    staticsites_partition4 = "staticSites"
    staticsites_partition5 = "staticSites"
    staticsites_partition6 = "staticSites"
    registry               = "registry"
    none                   = "none"
  }

  private_dns_zone_name = lookup(local.dns_zone_name, var.resource_type)
  subresource_name      = lookup(local.pvt_subresource, var.resource_type)

}

resource "azurerm_private_dns_zone" "dns" {
  name                = var.dnszone_mod_override == null ? local.private_dns_zone_name : var.dnszone_mod_override
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, var.extra_tags)
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each              = { for link in var.link_vnet : link.link_vnet_name => link }
  name                  = var.dnszone_mod_override == null ? join("-", [each.value.link_vnet_name, local.subresource_name, "link"]) : join("-", [var.dnszone_mod_override, "link"])
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = each.value.link_vnet_id
  registration_enabled  = false
}

