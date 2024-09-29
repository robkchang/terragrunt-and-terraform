variable "extra_tags" {
  type        = map(string)
  description = "Extra tags to merge with the tags map"
  default     = {}
}
variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}
variable "tags" {
  type        = map(string)
  description = "Tags that the resource should have"
  default     = {}
}
variable "location" {
  type        = string
  description = "The geographical location of the resource"
}
variable "vnet_address_space" {
  type = list(string)
}