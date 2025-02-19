terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = "https://192.168.124.2:8006/api2/json"

  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = "root@pam!semaphore"

  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = var.api_token

  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true
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

# resource is formatted to be "[type]" "[entity_name]" so in this case
# we are looking to create a proxmox_vm_qemu entity named test_server
resource "proxmox_vm_qemu" "test_server" {
  #count = 1 # just want 1 for now, set to 0 and apply to destroy VM
  name = "test-vm-1" #${count.index + 1}" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox

  target_node = "pve"

  # basic VM settings here. agent refers to guest agent
  agent    = 1
  os_type  = "cloud-init"
  cpu_type = "host"
  cores    = 1
  sockets  = 1
  memory   = 2048
  scsihw   = "virtio-scsi-pci"
  onboot   = false

  disks {
    ide {
      ide0 {
        cdrom {
          iso = "ubuntu-24.04.1-live-server-amd64.iso"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = "10G"
          storage = "local-lvm"
        }
      }
    }
  }

  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    id        = 0
    model     = "virtio"
    bridge    = "vmbr0"
    firewall  = false
    link_down = false
  }

  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  # the ${count.index + 1} thing appends text to the end of the ip address
  # in this case, since we are only adding a single VM, the IP will
  # be 10.98.1.91 since count.index starts at 0. this is how you can create
  # multiple VMs and have an IP assigned to each (.91, .92, .93, etc.)

  
  # Cloud init settings
  boot         = "order=ide0;scsi0"
  ciuser       = "sysadmin"
  cipassword   = var.ci_user_password
  ipconfig0    = "ip=192.168.124.100/24,gw=192.168.122.1"
  sshkeys      = var.ssh_key
}