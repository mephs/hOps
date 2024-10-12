locals {
  vm_gateway         = "172.20.10.1"
  cloud_init_user    = "cloud-init"
  cloud_init_ssh_key = file("~/.ssh/id_ed25519.pub")
  almalinux_template = "almalinux-9.4-20240507-cloud"
  lb_vms = {
    lb-01 = { id = 500, node = "pve-01", ip = "172.20.10.15/24" }
    lb-02 = { id = 501, node = "pve-02", ip = "172.20.10.16/24" }
  }
}

module "load_balancer" {
  source = "./modules/pve-vm"

  for_each = local.lb_vms

  vm_name       = each.key
  vm_id         = each.value.id
  vm_tags       = ["loadbalancer"]
  target_node   = each.value.node
  template_name = local.almalinux_template

  vm_ip               = each.value.ip
  vm_gateway          = local.vm_gateway
  cloud_init_user     = local.cloud_init_user
  cloud_init_ssh_keys = [local.cloud_init_ssh_key]
}
