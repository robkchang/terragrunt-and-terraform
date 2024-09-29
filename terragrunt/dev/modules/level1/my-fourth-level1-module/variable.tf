variable "dnszone_mod_override" {
  type        = string
  description = "If this variable is set, module will not append private endpoints"
  default     = null
}
variable "extra_tags" {
  type        = map(string)
  description = "Extra resource tags to add"
  default     = {}
}
variable "link_vnet" {
  type = list(object({
    link_vnet_id   = string
    link_vnet_name = string
  }))
  description = "A List of Keyvaults with Certificates to feed the Application Gateway"
}
variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group for this deployment"
}
variable "resource_type" {
  type = string
}
variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}