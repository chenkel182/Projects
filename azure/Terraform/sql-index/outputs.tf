output "id" {
  value = "${azurerm_key_vault.vault_store.id}"
}

output "uri" {
  value = "${azurerm_key_vault.vault_store.vault_uri}"
}