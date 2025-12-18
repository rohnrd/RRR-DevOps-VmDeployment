variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "location" {
  description = "Azure region for resources (used when creating new resources)"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM(s)"
  type        = string
}

variable "admin_password" {
  description = "Admin password (Windows) or password fallback for Linux"
  type        = string
  sensitive   = true
  default     = ""
}

variable "admin_ssh_key" {
  description = "Public SSH key to provision for Linux VMs (optional)"
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "os_type" {
  description = "Operating system type: \"windows\" or \"linux\""
  type        = string
  default     = "windows"
  validation {
    condition     = contains(["windows", "linux"], lower(var.os_type))
    error_message = "os_type must be either \"windows\" or \"linux\""
  }
}

variable "use_existing_resource_group" {
  description = "If true, use `existing_resource_group_name` instead of creating a new RG"
  type        = bool
  default     = false
}

variable "existing_resource_group_name" {
  description = "Name of an existing resource group to use (when `use_existing_resource_group` is true)"
  type        = string
  default     = ""
}

variable "use_existing_subnet" {
  description = "If true, use `existing_subnet_id` instead of creating a new vnet/subnet"
  type        = bool
  default     = false
}

variable "existing_subnet_id" {
  description = "ID of an existing subnet to attach NICs to (when `use_existing_subnet` is true)"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "Name for the VNet to create (when not using existing subnet). If empty, module will derive from name_prefix."
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Name for the Subnet to create (when not using existing subnet)"
  type        = string
  default     = "default"
}

variable "create_public_ip" {
  description = "Whether to create a public IP for each VM's NIC"
  type        = bool
  default     = true
}
