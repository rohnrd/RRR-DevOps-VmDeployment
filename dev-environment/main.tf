locals {
  adopter_json_data = jsondecode(file("${path.module}/data/adopter_parameters.json"))
}
# Generate SSH key automatically for Linux VMs
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "windows_vm" {
  source = "../modules/windows_vm"
  name_prefix                   = local.adopter_json_data.general.name_prefix
  location                      = local.adopter_json_data.general.location
  admin_username                = local.adopter_json_data.general.admin_username
  admin_password                = local.adopter_json_data.general.admin_password
  admin_ssh_key                 = local.adopter_json_data.general.admin_ssh_key != "" ? local.adopter_json_data.general.admin_ssh_key : tls_private_key.ssh.public_key_openssh
  vm_size                       = length(local.adopter_json_data.general.vms) > 0 ? local.adopter_json_data.general.vms[0].vm_size : "Standard_D2s_v3"
  vm_count                      = length(local.adopter_json_data.general.vms)
  os_type                       = length(local.adopter_json_data.general.vms) > 0 ? local.adopter_json_data.general.vms[0].os_type : "windows"
  use_existing_resource_group   = local.adopter_json_data.general.use_existing_resource_group
  existing_resource_group_name  = local.adopter_json_data.general.existing_resource_group_name
  use_existing_subnet           = local.adopter_json_data.general.use_existing_subnet
  existing_subnet_id            = local.adopter_json_data.general.existing_subnet_id
  create_public_ip              = local.adopter_json_data.general.create_public_ip
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
