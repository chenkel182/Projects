variable "resource_group_name" {}

variable "location" {
  default = "eastus"
}

variable "virtual_network_name" {
  default = ""
}

variable "subnet_name" {
  default = "dev"
}

variable "subnet_id" {
  description = "The subnet id of the virtual network on which the vm scale set will be connected"
}
