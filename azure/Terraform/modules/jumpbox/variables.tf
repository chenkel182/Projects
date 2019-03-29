#Update code here

variable "resource_group_name" {
  default = "dev"
}

variable "storage_account" {
  default = "dev_storage_account"
}

variable "environment" {
  default = "dev"
}

variable "application" {
  default = "jumpbox"
}

variable "location" {
  default = "eastus"
}

variable "vm_size" {
  default = "add default"
}

variable "vm_admin_username" {
  description = "Specify an admin username that should be used to login to the VM. Min length: 1"
  default = "centos"
}

variable "vm_admin_password" {
  description = "Specify an admin password that should be used to login to the VM. Must be between 6-72 characters long and must satisfy at least 3 of password complexity requirements from the following: 1) Contains an uppercase character 2) Contains a lowercase character 3) Contains a numeric digit 4) Contains a special character"
  default = "12345test!"
}

variable "vm_master_name" {
  default = "centos-vm"
}