resource "azurerm_resource_group" "rg" {
  name     = "jumpbox"
  location = "eastus"

  tags {
    environment = "Dev"
  }
}

resource "azurerm_virtual_network" "azure-vn" {
  name                = "monitoring"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "monitoring"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.azure-vn.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "publicip" {
  name                         = "myPublicIP"
  location                     = "eastus"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "Dev"
  }
}

resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Dev"
  }
}

resource "azurerm_network_interface" "myterraformnic" {
  name                = "myNIC"
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
  }

  tags {
    environment = "Dev"
  }
}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.rg.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
  name                = "diag${random_id.randomId.hex}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "eastus"
  account_replication_type = "LRS"
  account_tier = "Standard"

  tags {
    environment = "Dev"
  }
}

resource "azurerm_virtual_machine" "myterraformvm" {
  name                  = "Centos"
  location              = "eastus"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
  vm_size               = "Standard_D2_v3"

  storage_os_disk {
    name              = "myOsDisk"
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
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type = "ssh"
    host = "${azurerm_public_ip.publicip.ip_address}"
    user = "${var.vm_admin_username}"
    password = "${var.vm_admin_password}"
  }

    boot_diagnostics {
      enabled = "true"
      storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
      environment = "Terraform Demo"
    }
}