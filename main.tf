terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_secret    = "C7V8Q~5faa6TdQjEv19oyThxkJV~tXuKfcPwFaQf"
  client_id        = "4b886b48-5322-4095-984e-31ebd473b74a"
  subscription_id  = "b31981cb-9cb8-4bb1-b658-f4d690f23df5"
  tenant_id        = "141f9ef8-2c12-4303-a488-3dab2f113573"

}

resource "azurerm_resource_group" "rg" {
  name     = "${var.rgname}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                 = "${var.prefix}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  location             = "${azurerm_resource_group.rg.location}"
  address_space        = ["${var.vnet_cidr_prefix}"]
}

resource "azurerm_subnet" "subnet1" {
  name                  = "var.subnet"
  virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}" 
  address_prefixes      = ["${var.subnet1_cidr_prefix}"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
}

resource "azurerm_network_security_rule" "rdp" {
  name = "rdp"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_subnet_network_security_group_association" "subnet_network_assoc" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
   name                = "${var.prefix}-nic"
   resource_group_name = "${azurerm_resource_group.rg.name}"
   location            = "${azurerm_resource_group.rg.location}"

   ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
   }
}

resource "azurerm_windows_virtual_machine" "winmachine" {
  name = "winmachine"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  location              = "${azurerm_resource_group.rg.location}"
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  admin_password        = "123456789aA#"
  network_interface_ids = [azurerm_network_interface.nic.id]

  source_image_reference {
    publisher    = "MicrosoftWindowsServer"
    offer        = "WindowsServer"
    sku          = "2019-Datacenter"
    version      = "latest"
  }
    os_disk {
      storage_account_type = "Standard_LRS"
      caching             = "ReadWrite"
    }
}
