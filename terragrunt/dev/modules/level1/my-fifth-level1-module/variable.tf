variable "container_name" {
  description = "Specifies the name of the Container. Changing this forces a new resource to be created."
  type        = string
}
variable "cpu" {
  description = "The required number of CPU cores of the containers. Changing this forces a new resource to be created."
  type        = string
}
variable "extra_tags" {
  type        = map(string)
  description = "Extra resource tags to add"
  default     = {}
}
variable "image" {
  description = "The container image name. Changing this forces a new resource to be created."
  type        = string
}
variable "ip_address_type" {
  description = "Specifies the ip address type of the container. Public or Private"
  type        = string
}
variable "location" {
  type        = string
  description = "The location where resources will be created"
}
variable "memory" {
  description = "The required memory of the containers in GB. Changing this forces a new resource to be created."
  type        = string
}
variable "name" {
  type        = string
  description = "Name of the resource"
}
variable "os_type" {
  description = "The OS for the container group"
  type        = string
}
variable "port" {
  description = "A set of public ports for the container."
  type        = number
}
variable "protocol" {
  description = "The network protocol associated with port."
  type        = string
}
variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}
variable "tags" {
  type        = map(string)
  description = "Tags that the resource should have"
  default = {}
}
variable "location" {
  type        = string
  description = "The geographical location of the resource"
}