variable "extra_tags" {
    type = map
    description = "Extra tags to merge with the tags map"
}
variable "resource_group_name" {
    type = string
    description = "Resource group name"
}
variable "tags" {
    type = map
    description = "Tags that the resource should have"
}
variable "location" {
    type = string
    description = "The geographical location of the resource"
}