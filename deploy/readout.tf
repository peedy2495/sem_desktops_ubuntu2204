data "http" "vm_info" {
  url = "https://192.168.124.2:8006/api2/json/nodes/pve/qemu/100/config"
  request_headers = {
    Authorization = "PVEAPIToken=root@pam!semaphore=${var.api_token}"
  }
  tls_server_name = "192.168.124.72"
}

output "vm_info" {
  value = data.http.vm_info.body
}
