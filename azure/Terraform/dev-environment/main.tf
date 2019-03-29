resource "azurerm_resource_group" "rg" {
  name = "${var.resource_group_name}"
  location = "${var.location}"

  tags {
    environment = "${var.environment}"
    provisoner  = "terraform"
  }
}

module "dns" {
  source = "../modules/dns"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  public_domain_name = "test.dev.com"
}

module "networking" {
  source = "../modules/networking"
  location  = "${var.location}"
  virtual_network_name  = "${var.virtual_network_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  subnet_id = "${module.networking.subnet_id}"
}

output "subnet_id" {
  description = "The ids of subnets created inside the new vNet"
  value       = "${azurerm_subnet.subnet.id}"
}

resource "azurerm_storage_account" "storage" {
  name = "${var.storage_account}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    environment = "${var.environment}"
    provisoner = "terraform"
  }
  account_replication_type = "LRS"
  account_tier = "Standard"
}

# module "chef" {
#   source = "../modules/chef"
#   subnet_id = "${module.networking.subnet_id}"
#   # depends_on = "{azurerm_resource_group.rg}"
# }
