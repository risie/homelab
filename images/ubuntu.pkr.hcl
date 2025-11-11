packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu" {
  # Proxmox connection
  proxmox_url              = "https://192.168.68.100:8006/api2/json"
  username                 = "${env("PROXMOX_USER")}"
  token                    = "${env("PROXMOX_TOKEN")}"
  insecure_skip_tls_verify = true
  node                     = "proxmox"

  # VM settings
  vm_id   = 9000
  vm_name = "ubuntu-2204-template"
  memory  = 2048
  cores   = 2
  sockets = 1

  # Network
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Disk
  disks {
    type         = "scsi"
    disk_size    = "20G"
    storage_pool = "local-lvm"
    format       = "raw"
  }

  # Ubuntu 22.04 ISO
  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
  iso_checksum     = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
  iso_storage_pool = "local"
  unmount_iso      = true

  # SSH
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout  = "20m"

  # Boot commands for Ubuntu autoinstall
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot_wait = "5s"

  # Serve autoinstall files via HTTP
  http_directory = "http"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  # Wait for cloud-init to finish
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }

  # Install qemu-guest-agent
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y qemu-guest-agent"
    ]
  }
}
