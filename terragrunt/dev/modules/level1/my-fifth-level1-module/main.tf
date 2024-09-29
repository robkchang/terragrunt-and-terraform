resource "azurerm_network_profile" "aci" {
  count               = var.ip_address_type == "Private" ? 1 : 0
  name                = "aci-vnic"
  location            = var.location
  resource_group_name = var.resource_group_name

  container_network_interface {
    name = "nic"

    ip_configuration {
      name      = "ipconfig"
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_container_group" "aci" {
  name                = join("-", [var.name, "aci"])
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_address_type = var.ip_address_type
  #  network_profile_id = var.ip_address_type == "Private" ? azurerm_network_profile.aci[0].id : null
  subnet_ids     = var.ip_address_type == "Private" ? [var.subnet_id] : null
  os_type        = var.os_type
  restart_policy = var.restart_policy

  container {
    name   = var.container_name
    image  = var.image
    cpu    = var.cpu
    memory = var.memory

    ports {
      port     = var.port
      protocol = var.protocol
    }
  }

  tags = merge(var.tags, var.extra_tags)
}