data "proxmox" "vm_info" {
  path = "/nodes/pve/qemu/100/config"
}

output "vm_info" {
  value = data.http.vm_info.body
}
