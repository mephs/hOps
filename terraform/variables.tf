#
# Optional Variables
#

variable "pve_ignore_tls" {
  type        = bool
  default     = true
  description = "Disable TLS verification of the Proxmox API."
}
