variable "actions" {
  type        = list(string)
  description = "A list of Actions which should be delegated. This list is specific to the service to delegate to"
  default     = null
}
variable "enable_nsg" {
  type        = bool
  description = "Toggle to create or skip NSG creation"
  default     = true
}
variable "enable_subnet_delegation" {
  type        = bool
  description = "Toggle to Enable/Disable Subnet Delegation"
  default     = false
}
variable "enable_udr" {
  type        = bool
  description = "Toggle to create or skip UDR Creation"
  default     = false
}
variable "extra_tags" {
  type        = map(string)
  description = "Extra tags to merge with the tags map"
  default = {}
}
variable "location" {
  type        = string
  description = "The geographical location of the resource"
}
variable "nsg_rules" {
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_ranges           = string
    destination_port_range       = string
    destination_port_ranges      = string
    source_address_prefix        = string
    source_address_prefixes      = string
    destination_address_prefix   = string
    destination_address_prefixes = string
  }))
}
variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}
variable "service_endpoints" {
  type        = list(string)
  description = "The list of service endpoints to associate with the subnet"
  default     = Null
}
variable "services_to_delegate" {
  type        = string
  description = "A name for this delegation"
  default     = null
}
variable "subnet_name" {
  type        = string
  description = "Name of the subnet"
}
variable "subnet_not_have_private_endpoints" {
  type        = bool
  description = "Enable or Disable network policies for the private link endpoint on the subnet"
  default     = null
}
variable "subnet_not_have_private_services" {
  type        = bool
  description = "Enable or Disable network policies for the private link service on the subnet"
  default     = null
}
variable "subnet_priceses" {
  type        = list(string)
  description = "IP CIDR for the new subnet"
}
variable "tags" {
  type        = map(string)
  description = "Tags that the resource should have"
  default = {}
}
variable "udr_routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))
  default = null
}
variable "vnet_name" {
  type        = string
  description = "name of the vnet to create"
}