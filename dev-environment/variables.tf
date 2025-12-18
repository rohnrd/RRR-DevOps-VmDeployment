variable "name_prefix" {
  description = "Prefix for resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "admin_username" {
  description = "VM admin username"
  type        = string
}

variable "admin_password" {
  description = "VM admin password"
  type        = string
  sensitive   = true
}

variable "admin_ssh_key" {
  description = "Public SSH key for Linux VMs (optional)"
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "os_type" {
  description = "OS type for VMs: windows or linux"
  type        = string
  default     = "windows"
}

variable "use_existing_resource_group" {
  description = "If true, use an existing resource group"
  type        = bool
  default     = false
}

variable "existing_resource_group_name" {
  description = "Name of existing resource group (when using existing)"
  type        = string
  default     = ""
}

variable "use_existing_subnet" {
  description = "If true, attach NICs to an existing subnet by ID"
  type        = bool
  default     = false
}

variable "existing_subnet_id" {
  description = "ID of an existing subnet to attach NICs to"
  type        = string
  default     = ""
}

variable "create_public_ip" {
  description = "Whether to create a public IP for each VM's NIC (module pass-through)"
  type        = bool
  default     = true
}
