locals {
  tags      = join(",", var.vm_tags)
  ipconfig0 = var.vm_ip == "dhcp" ? "ip=dhcp" : "ip=${var.vm_ip},gw=${var.vm_gateway}"
  sshkeys   = join("\n", var.cloud_init_ssh_keys)
}

resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = var.target_node
  desc        = var.vm_desc
  tags        = local.tags
  clone       = var.template_name
  vmid        = var.vm_id
  agent       = var.qemu_agent ? 1 : 0
  onboot      = var.start_on_boot
  os_type     = "cloud-init"
  cpu         = var.cpu_type
  sockets     = var.sockets
  cores       = var.cores
  vcpus       = var.vcpus
  memory      = var.memory_mb
  scsihw      = var.scsi_hw
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.os_disk.storage_pool
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size     = var.os_disk.size
          storage  = var.os_disk.storage_pool
          backup   = var.os_disk.backup
          iothread = var.os_disk.iothread
        }
      }
      dynamic "virtio1" {
        for_each = var.extra_disk.size != null ? [var.extra_disk] : []
        content {
          disk {
            size     = each.value.size
            storage  = each.value.storage_pool
            backup   = each.value.backup
            iothread = each.value.iothread
          }
        }
      }
    }
  }
  # Enable console output
  serial {
    id = 0
  }
  ciuser       = var.cloud_init_user
  cipassword   = var.cloud_init_password
  ciupgrade    = var.cloud_init_upgrade
  ipconfig0    = local.ipconfig0
  nameserver   = var.nameserver
  searchdomain = var.searchdomain
  sshkeys      = local.sshkeys
}
