#
# Required
#

variable "vm_name" {
  type        = string
  description = "The name of the VM."
}

variable "target_node" {
  type        = string
  description = "The Proxmox node where the VM will be created."
}

variable "template_name" {
  type        = string
  description = "Name of Proxmox VM template to clone."
}

variable "cloud_init_ssh_keys" {
  type        = list(string)
  description = "Setup public SSH keys."
}

#
# Optional
#

variable "vm_id" {
  type        = number
  default     = 0
  description = "The ID of the VM in Proxmox. The default value of 0 indicates it should use the next available ID in the sequence."
}

variable "qemu_agent" {
  type        = bool
  default     = true
  description = "Enables or disables the QEMU guest agent."
}

variable "start_on_boot" {
  type        = bool
  default     = true
  description = "Specifies whether to start the VM when the Proxmox VE node boots."
}

variable "vm_desc" {
  type        = string
  default     = null
  description = "A brief description of the VM's purpose."
}

variable "vm_tags" {
  type        = list(string)
  default     = []
  description = "Tags of the VM."
  validation {
    condition     = alltrue([for tag in var.vm_tags : can(regex("^[0-9a-z_]+$", tag))])
    error_message = "Can only include the following characters: [a-z], [0-9], and _."
  }
}

variable "cpu_type" {
  type        = string
  default     = "host"
  description = "The CPU type to emulate in the guest VM."
}

variable "sockets" {
  type        = number
  default     = 1
  description = "The number of CPU sockets to assign to the VM."
}

variable "cores" {
  type        = number
  default     = 2
  description = "The number of CPU cores assigned to the VM."
}

variable "vcpus" {
  type        = number
  default     = 0
  description = "The number of virtual CPUs assigned to the VM. Set to 0 to use the default configuration."
}

variable "memory_mb" {
  type        = number
  default     = 2048
  description = "The amount of memory allocated to the VM in megabytes."
}

variable "scsi_hw" {
  type        = string
  default     = "virtio-scsi-pci"
  description = "The SCSI controller type to emulate for the VM. Supported types are: lsi, lsi53c810, megasas, pvscsi, virtio-scsi-pci, and virtio-scsi-single."
  validation {
    condition     = contains(["lsi", "lsi53c810", "megasas", "pvscsi", "virtio-scsi-pci", "virtio-scsi-single"], var.scsi_hw)
    error_message = "Unsupported SCSI controller type. Valid options are: lsi, lsi53c810, megasas, pvscsi, virtio-scsi-pci, or virtio-scsi-single."
  }
}

variable "os_disk" {
  type = object({
    size         = string
    storage_pool = optional(string, "local-zfs")
    backup       = optional(bool, true)
    iothread     = optional(bool, true)
  })
  default     = { size = "10G" }
  description = "Disk configuration."
  validation {
    condition     = can(regex("^[1-9][0-9]*[KMGT]?$", var.os_disk.size))
    error_message = "Wrong disk size format."
  }
}

variable "extra_disk" {
  type = object({
    size         = string
    storage_pool = optional(string, "local-zfs")
    backup       = optional(bool, true)
    iothread     = optional(bool, true)
  })
  default     = { size = null }
  description = "Disk configuration."
  validation {
    condition     = var.extra_disk.size == null || can(regex("^[1-9][0-9]*[KMGT]?$", var.extra_disk.size))
    error_message = "Wrong disk size format."
  }
}

variable "cloud_init_user" {
  type        = string
  default     = "deploy"
  description = "Default cloud-init user."
}

variable "cloud_init_password" {
  type        = string
  default     = null
  description = "Password for the cloud-init user."
  sensitive   = true
}

variable "cloud_init_upgrade" {
  type        = bool
  default     = false
  description = "Upgrade the packages on the guest during provisioning."
}

variable "nameserver" {
  type        = string
  default     = null
  description = "Sets default DNS server for guest."
}

variable "searchdomain" {
  type        = string
  default     = null
  description = "Sets default DNS search domain suffix."
}

variable "vm_ip" {
  type        = string
  default     = "dhcp"
  description = "IPv4 address in CIDR format. . The special string 'dhcp' can be used for IP address to use DHCP."
  validation {
    condition     = var.vm_ip == "dhcp" || can(cidrhost(var.vm_ip, 0))
    error_message = "Must be valid IPv4 in CIDR format, or 'dhcp' string."
  }
}

variable "vm_gateway" {
  type        = string
  default     = null
  description = "Default gateway for IPv4 traffic."
  validation {
    condition     = var.vm_gateway == null || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.vm_gateway))
    error_message = "Must be valid IPv4."
  }
  validation {
    condition     = var.vm_ip == "dhcp" || var.vm_gateway != null
    error_message = "'vm_gateway' must be specified if 'vm_ip' is not set to 'dhcp'."
  }
}
