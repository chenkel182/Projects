resource "azurerm_resource_group" "chef" {
  name = "${var.environment}-${var.application}"
  location = "${var.location}"

  tags {
    environment = "${var.environment}"
    application = "${var.application}"
  }
}

resource "azurerm_storage_account" "chef" {
  name = "${var.environment}${var.application}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.chef.name}"

  tags {
    environment = "${var.environment}"
    application = "${var.application}"
  }
  account_replication_type = "LRS"
  account_tier = "Standard"
}

resource "azurerm_storage_container" "chef" {
  name                  = "${var.environment}-${var.application}"
  resource_group_name   = "${azurerm_resource_group.chef.name}"
  storage_account_name  = "${azurerm_storage_account.chef.name}"
  container_access_type = "private"
  }

resource "azurerm_availability_set" "chef" {
name                = "${var.environment}-${var.application}-availset"
location            = "${var.location}"
resource_group_name = "${azurerm_resource_group.chef.name}"

tags {
provisioned-by = "terraform"
environment    = "${var.environment}"
application    = "${var.application}"
  }
}

#not sure if needed
//
//resource "azurerm_storage_blob" "basevhd" {
//    name = "base-image.vhd"
//
//    resource_group_name    = "${azurerm_resource_group.chef.name}"
//    storage_account_name   = "${azurerm_storage_account.chef.name}"
//    storage_container_name = "${azurerm_storage_container.chef.name}"
//
//    source_uri = "${var.uri}"
//    type       = "page"
//  }

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "vault_store" {
  name                        = "chef-keystore"
  location                    = "${var.location}"
  resource_group_name         = "${azurerm_resource_group.chef.name}"
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

resource "azurerm_key_vault_key" "generated" {
  name      = "chef-dev"
  key_type  = "RSA"
  key_size  = 2048
  vault_uri = "${azurerm_key_vault.vault_store.vault_uri}"

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}


resource "azurerm_virtual_network" "network" {
  name = "virtualNetwork1"
  location = "${azurerm_resource_group.chef.location}"
  resource_group_name = "${azurerm_resource_group.chef.name}"
  address_space = [
    "10.0.0.0/16"]
  dns_servers = [
    "10.0.0.4",
    "10.0.0.5"]
}

resource "azurerm_subnet" "chef-subnet" {
  name                 = "chef-subnet"
  resource_group_name  = "${azurerm_resource_group.chef.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_network_interface" "chef" {
  name                = "${var.environment}-${var.application}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.chef.name}"
  dns_servers         = ["8.8.8.8", "8.8.4.4"]

  ip_configuration {
    name                          = "${var.environment}-${var.application}-nic-conf1"
    subnet_id                     = "${azurerm_subnet.chef-subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.1.5"
  }
}

resource "template_file" "chef_userdata" {
  template = "${file("chef_userdata.tpl")}"

  vars {
    domain_name = "${var.domain_name}"
  }
}

resource "template_file" "chef_bootstrap" {
  template = "${file("chef_bootstrap.tpl")}"

  vars {
    chef_username = "${var.chef_username}"
    chef_user = "${var.chef_user}"
    chef_password = "${var.chef_password}"
    chef_user_email = "${var.chef_user_email}"
    chef_organization_id = "${var.chef_organization_id}"
    chef_organization_name = "${var.chef_organization_name}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${template_file.chef_bootstrap.rendered}"
  }
}

resource "azurerm_virtual_machine" "chef" {
  name                  = "Chef-Server"
  location              = "eastus"
  resource_group_name   = "${azurerm_resource_group.chef.name}"
  network_interface_ids = ["${azurerm_network_interface.chef.id}"]
  vm_size               = "Standard_D2_v3"

  storage_os_disk {
    name              = "chef-Disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }

  os_profile {
    computer_name = "${var.vm_master_name}"
    admin_username = "${var.username}"
    admin_password = "${uuid()}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = [{
      path     = "/home/centos/.ssh/authorized_keys"
//      key_data = "${azurerm_key_vault_key.generated.n}" working on getting the connection to azure keystore working
      key_data = "${file("/root/.ssh/chef_rsa.pub")}"
    }]
  }

  connection {
    type = "ssh"
    host = "${azurerm_network_interface.chef.private_ip_address}"
    user = "${var.username}"
//    private_key = "${file(var.ssh_private_key_path)}"

  }

  tags {
    environment = "Dev"
    provisioner = "Terraform"
  }
  provisioner "remote-exec" {
    connection {
      user = "centos"
    }
    inline = [
      "echo '${template_file.chef_bootstrap.rendered}' > /tmp/bootstrap-chef-server.sh",
      "chmod +x /tmp/bootstrap-chef-server.sh",
      "sudo sh /tmp/bootstrap-chef-server.sh"
    ]
  }
}
