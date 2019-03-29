data "azurerm_client_config" "current" {}
module "azurerm_key_vault" "vault_store" {
  name                        = "${var.environment}-keystore"
  location                    = "${var.location}"
  resource_group_name         = "${var.resource_group_name}"
  tenant_id                   = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

    key_permissions = [
      "create",
      "get",
      "list",
    ]

    secret_permissions = [
      "set",
      "get",
    ]
  }
  tags {
  environment = "${var.environment}"
  }
}

//Key Example  -- Define a new key to associate with your VM tf code

# resource "azurerm_key_vault_key" "generated" {
#   name      = "chef-dev"
#   key_type  = "RSA"
#   key_size  = 2048
#   vault_uri = "${azurerm_key_vault.vault_store.vault_uri}"

#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]
# }