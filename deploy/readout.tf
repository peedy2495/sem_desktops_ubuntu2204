data "http" "vm_info" {
  url = "https://192.168.124.2:8006/api2/json"

  request_headers = {
    Authorization = "PVEAPIToken=root@pam!semaphore=${var.api_token}"
  }
}

output "vm_config" {
  value = data.http.vm_info.body
}
