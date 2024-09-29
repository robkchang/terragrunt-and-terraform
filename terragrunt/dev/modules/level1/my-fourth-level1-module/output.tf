output "dns_zone_id" {
  description = "The id of the ASE"
  value       = azurerm_private_dns_zone.dns.id
}
output "dns_zone_name" {
  description = "The id of the ASE"
  value       = azurerm_private_dns_zone.dns.name
}