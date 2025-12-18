output "resource_group_name" {
  value = var.use_existing_resource_group ? var.existing_resource_group_name : azurerm_resource_group.rg[0].name
}

output "vm_ids" {
  value = concat(
    azurerm_windows_virtual_machine.windows_vm[*].id,
    azurerm_linux_virtual_machine.linux_vm[*].id,
  )
}

output "public_ips" {
  value = azurerm_public_ip.pip[*].ip_address
}

output "nic_ids" {
  value = azurerm_network_interface.nic[*].id
}
