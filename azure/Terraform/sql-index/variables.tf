#we want our variables to be unique per statefile

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "automation_name" {
  type = "string"
}

variable "automation_account_name" {}

variable "key_vault" {}

variable "vault_uri" {}

variable "password_value" {}

variable "start_time" {}

variable "environment" {}

variable "tenant_id" {}

variable "object_id" {}

variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
    name   = "chenkel-test"
  }
}
