# Generate SSH key automatically for Linux VMs
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "windows_vm" {
  source = "../modules/windows_vm"
  name_prefix                   = var.name_prefix
  location                      = var.location
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  admin_ssh_key                 = var.admin_ssh_key != "" ? var.admin_ssh_key : tls_private_key.ssh.public_key_openssh
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

output "ssh_private_key" {
  description = "Private SSH key for Linux VMs (save this securely!)"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "Public SSH key for Linux VMs"
  value       = tls_private_key.ssh.public_key_openssh
}
