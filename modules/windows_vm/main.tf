locals {
  os_type_lower = lower(var.os_type)
}

data "azurerm_resource_group" "existing" {
  count = var.use_existing_resource_group ? 1 : 0
  name  = var.existing_resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.use_existing_resource_group ? 0 : 1
  name     = "${var.name_prefix}-rg"
  location = var.location
}

# Determine resource group name and location for created resources
locals {
  resource_group_name = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].name : azurerm_resource_group.rg[0].name
  resource_group_loc  = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : var.location
}

# Create VNet/Subnet only when not using an existing subnet
resource "azurerm_virtual_network" "vnet" {
  count               = var.use_existing_subnet ? 0 : 1
  name                = var.vnet_name != "" ? var.vnet_name : "${var.name_prefix}-vnet"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_loc
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  count                = var.use_existing_subnet ? 0 : 1
  name                 = var.subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = var.use_existing_subnet ? "" : azurerm_virtual_network.vnet[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

# final subnet id to use for NIC attachments
locals {
  subnet_id = var.use_existing_subnet && var.existing_subnet_id != "" ? var.existing_subnet_id : (var.use_existing_subnet && var.existing_subnet_id == "" ? (data.azurerm_subnet.existing[0].id) : azurerm_subnet.subnet[0].id)
}

data "azurerm_subnet" "existing" {
  count = var.use_existing_subnet && var.existing_subnet_id != "" ? 0 : (var.use_existing_subnet && var.existing_subnet_id == "" ? 1 : 0)
  # When an existing subnet is desired but only name/vnet provided, user must provide the following values.
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.existing_resource_group_name
}

resource "azurerm_public_ip" "pip" {
  count               = var.create_public_ip ? var.vm_count : 0
  name                = "${var.name_prefix}-pip-${count.index + 1}"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_loc
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.name_prefix}-nic-${count.index + 1}"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_loc

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.pip[count.index].id : null
  }
}

# Create Windows VMs only when os_type is windows
resource "azurerm_windows_virtual_machine" "windows_vm" {
  count                = local.os_type_lower == "windows" ? var.vm_count : 0
  name                 = "${var.name_prefix}-win-${count.index + 1}"
  resource_group_name  = local.resource_group_name
  location             = local.resource_group_loc
  size                 = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Create Linux VMs only when os_type is linux
resource "azurerm_linux_virtual_machine" "linux_vm" {
  count               = local.os_type_lower == "linux" ? var.vm_count : 0
  name                = "${var.name_prefix}-lin-${count.index + 1}"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_loc
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_key != "" ? [var.admin_ssh_key] : []
    content {
      username   = var.admin_username
      public_key = admin_ssh_key.value
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
