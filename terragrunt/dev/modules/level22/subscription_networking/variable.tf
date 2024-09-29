variable "address_spaces" {
  type        = map(list(string))
  description = "A map of address spaces and names for subnets"
}
variable "deploy_firewall" {
  type        = string
  description = "Toggle for the Firewall"
  default     = "No"
}
variable "extra_tags" {
  type        = map(string)
  description = "Extra resource tags to add"
}
variable "location" {
  type        = string
  description = "Region/Location of the resource"
}
variable "private_dns_zones" {
  type        = list(string)
  description = "A list of resources for which private DNS endpoints are needed"
}
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the resources will be created"
}
variable "subscription_name" {
  type        = string
  description = "The name of the subscription"
}
variable "tags" {
  type        = map(string)
  description = "Resource tags"
}
variable "vnet_address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
}




