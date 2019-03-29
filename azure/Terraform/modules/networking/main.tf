#Creates default Azure network used by the entire resource group

resource "azurerm_virtual_network" "vnetwork" {
  name = "${var.virtual_network_name}"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space = [
    "10.0.0.0/16"]
  dns_servers = [
    "10.0.0.4",
    "10.0.0.5"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${azurerm_virtual_network.vnetwork.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.vnetwork.name}"
  address_prefix       = "10.0.1.0/24"
}