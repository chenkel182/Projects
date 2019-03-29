variable "resource_group_name" {
  default = "dev"
}

variable "storage_account" {
  default = ""
}

variable "environment" {
  default = "dev"
}

variable "application" {
  default = "chef"
}

variable "location" {
  default = "eastus"
}

variable "vm_size" {
  default = "add default"
}

variable "username" {
  default = "centos"
}

variable "vm_master_name" {
  default = "chef-server"
}

variable "domain_name" {
  default = "example.com"
}

variable "chef_username" {
  default = "chef"
}

variable "chef_user" {
  default = "chef-user"
}

variable "chef_password" {
  default = "chef12345!"
}

variable "chef_user_email" {
  default = "chef@example.com"
}

variable "chef_organization_id" {
  default = "dev"
}

variable "chef_organization_name" {
  default = "dev"
}