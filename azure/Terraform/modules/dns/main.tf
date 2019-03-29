#https://www.terraform.io/docs/providers/azurerm/r/dns_zone.html

resource "azurerm_dns_zone" "public_dns" {
  name                = "${var.public_domain_name}"
  resource_group_name = "${var.resource_group_name}"
  zone_type           = "Public"
}
