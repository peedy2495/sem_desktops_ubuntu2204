terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

variable "api_token" {
  description = "API authentication token"
  sensitive   = true  # Optional: mark as sensitive if needed
}

variable "ssh_key" {
  description = "SSH pubclic key"
  sensitive   = true  # Optional: mark as sensitive if needed
}

variable "ci_user_password" {
  description = "administrative password"
  sensitive   = true  # Optional: mark as sensitive if needed
}

data "http" "vm_info" {
  url = "https://192.168.124.2:8006/api2/json"

  request_headers = {
    Authorization = "PVEAPIToken=root@pam!semaphore=${var.api_token}"
  }
}

output "vm_config" {
  value = data.http.vm_info.body
}
