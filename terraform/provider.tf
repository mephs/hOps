terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.1.1"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = var.pve_ignore_tls
}

provider "sops" {}
