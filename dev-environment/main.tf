module "windows_vm" {
  source = "../modules/windows_vm"
  name_prefix                   = var.name_prefix
  location                      = var.location
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  admin_ssh_key                 = var.admin_ssh_key
  vm_size                       = var.vm_size
  vm_count                      = var.vm_count
  os_type                       = var.os_type
  use_existing_resource_group   = var.use_existing_resource_group
  existing_resource_group_name  = var.existing_resource_group_name
  use_existing_subnet           = var.use_existing_subnet
  existing_subnet_id            = var.existing_subnet_id
  create_public_ip              = var.create_public_ip
}

output "vm_public_ips" {
  value = module.windows_vm.public_ips
}
