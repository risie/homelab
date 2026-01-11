resource "proxmox_virtual_environment_download_file" "kali_iso_image" {
  content_type  = "iso"
  datastore_id  = "local"
  node_name     = var.proxmox_node
  url           ="https://cdimage.kali.org/kali-2025.4/kali-linux-2025.4-qemu-amd64.7z"
  file_name     = "kali-linux-2025.4-qemu-amd64.iso"
}

resource "proxmox_virtual_environment_download_file" "kali_cloud_image" {
  content_type             = "iso"
  datastore_id            = "local"
  node_name               = var.proxmox_node
  decompression_algorithm = "zst"
  url                     = "https://kali.download/cloud-images/kali-2025.4/kali-linux-2025.4-cloud-genericcloud-amd64.tar.xz"
  checksum                = "649f20a4703f2324c0a5fa286a9260a5eb98d7f5d554d9aa179f284e8338fe8f"
  checksum_algorithm      = "sha256"
  file_name               = "kali-linux-2025.4-cloud-genericcloud-amd64.raw"
}

resource "proxmox_virtual_environment_vm" "kali_vm" {
  name      = "kali-vm"
  node_name = var.proxmox_node
  agent {
    enabled = true
     timeout = "60s"
  }

  stop_on_destroy = true
  memory {
    dedicated = 2048
    floating  = 2048 
  }
  cpu {
    cores = 2
    type  = "host"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disk {
    datastore_id = "local-lvm"
    file_id      =  proxmox_virtual_environment_download_file.kali_iso_image.id
    file_format  =  "raw"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
}
