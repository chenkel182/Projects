output "vnetwork_id" {
  description = "The id of the newly created vNet"
  value       = "${azurerm_virtual_network.vnetwork.id}"
}

output "vnetwork_name" {
  description = "The Name of the newly created vNet"
  value       = "${azurerm_virtual_network.vnetwork.name}"
}

output "subnet_id" {
  description = "The ids of subnets created inside the new vNet"
  value       = "${azurerm_subnet.subnet.id}"
}