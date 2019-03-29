

resource "azurerm_storage_container" "chef" {
  name                  = "${var.environment}-${var.application}"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${var.storage_account}"
  container_access_type = "private"
  }

resource "azurerm_availability_set" "chef" {
name                = "${var.environment}-${var.application}-availset"
location            = "${var.location}"
resource_group_name = "${var.resource_group_name}"

tags {
provisioned-by = "terraform"
environment    = "${var.environment}"
application    = "${var.application}"
  }
}

resource "azurerm_network_interface" "chef" {
  name                = "${var.environment}-${var.application}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  dns_servers         = ["8.8.8.8", "8.8.4.4"]

  ip_configuration {
    name                          = "${var.environment}-${var.application}-nic-conf1"
    subnet_id                     = "${data.azurerm_subnet.subnet_id.id}"
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
  resource_group_name   = "${var.resource_group_name}"
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