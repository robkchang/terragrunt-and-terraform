output "nsg_id" {
  value = azurerm_network_security_group.nsg.*.id
}
output "nsg_rule_id" {
  value = azurerm_network_security_rule.nsg_rule[*]
}
output "subnet_address_prefixes" {
  value = azurerm_subnet.subnet.address_prefixes
}
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
output "subnet_name" {
  value = azurerm_subnet.subnet.name
}