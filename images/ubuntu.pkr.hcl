packer {
  required_version = ">= 1.12.0"
  required_plugins {
    proxmox = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}


locals {
  boot_command = [
    "<wait3s>c<wait3s>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud-net\\;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

  build_date = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  vm_name    = "ubuntu-${var.vm_version}"

  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/http/meta-data")
    "/user-data" = templatefile("${abspath(path.root)}/http/user-data.pkrtpl.hcl", {
      vm_hostname      = var.vm_hostname
      vm_username      = var.vm_username
      vm_password_hash = var.vm_password_hash
      vm_timezone      = var.vm_timezone
      vm_locale        = var.vm_locale
      vm_keyboard      = var.vm_keyboard
    })
  }
}


source "proxmox-iso" "ubuntu" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = var.proxmox_insecure
  node                     = var.proxmox_node

  vm_name              = local.vm_name
  template_name        = local.vm_name
  template_description = "Ubuntu ${var.vm_version} template built on ${local.build_date}"

  bios            = "ovmf"
  machine         = "q35"
  os              = "l26"
  cpu_type        = var.vm_cpu_type
  cores           = var.vm_cpu_cores
  sockets         = var.vm_cpu_sockets
  memory          = var.vm_memory
  scsi_controller = "virtio-scsi-single"

  disks {
    type         = "virtio"
    disk_size    = var.vm_disk_size
    storage_pool = var.vm_storage_pool
    format       = "raw"
  }

  efi_config {
    efi_storage_pool  = var.vm_storage_pool
    efi_type          = "4m"
    pre_enrolled_keys = false
  }

  network_adapters {
    bridge = var.vm_bridge
    model  = "virtio"
  }

  boot_iso {
    iso_file     = "${var.iso_storage}:${var.iso_path}/${var.iso_file}"
    iso_checksum = var.iso_checksum
    unmount      = true
  }

  boot      = "order=virtio0;ide2;net0"
  boot_wait = "5s"
  boot_command = local.boot_command

  http_content = local.data_source_content

  ssh_username = var.vm_username
  ssh_password = var.vm_password
  ssh_timeout  = "20m"
  qemu_agent   = true

  cloud_init              = true
  cloud_init_storage_pool = var.vm_storage_pool
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "cloud-init status --wait"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y qemu-guest-agent cloud-init",
      "sudo systemctl enable qemu-guest-agent",
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm /var/lib/dbus/machine-id",
      "sudo ln -s /etc/machine-id /var/lib/dbus/machine-id"
    ]
  }
}
