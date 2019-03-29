#Create automation account

resource "azurerm_resource_group" "Create_Resource_Group" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_automation_account" "Automation" {
  name                = "${var.automation_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  sku {
    name = "Basic"
  }
}

resource "azurerm_automation_schedule" "daily" {
  name                    = "automation-index-schedule-daily"
  resource_group_name     = "${var.resource_group_name}"
  automation_account_name = "${var.automation_account_name}"
  frequency               = "Day"
  interval                = 1
  start_time              = "${var.start_time}"

}

resource "azurerm_key_vault" "vault_store" {
  name                        = "${var.key_vault}"
  location                    = "${var.location}"
  resource_group_name         = "${var.resource_group_name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.object_id}"

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
  }

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_key_vault_secret" "keyvault" {
  name = "${azurerm_key_vault.vault_store.name}"
  value = "${var.password_value}"
  vault_uri = "${azurerm_key_vault.vault_store.vault_uri}"
  depends_on = ["azurerm_key_vault.vault_store"]
}

resource "azurerm_automation_runbook" "MSSQL_Index_Daily" {
  name                = "MSSQL-Index-Run"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  account_name        = "Dev"
  log_verbose         = "true"
  log_progress        = "true"
  description         = "Runbook to run the indexing script on MSSQL servers"
  runbook_type        = "PowerShell"

  publish_content_link {
    uri = "https://github.com/olahallengren/sql-server-maintenance-solution/blob/master/CommandExecute.sql"
  }
}