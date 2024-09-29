resource "azurerm_virtual_notework" "vnet" {
  name                = var.resource_group_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = merge(
    var.tags,
    var.extra_tags
  )
}