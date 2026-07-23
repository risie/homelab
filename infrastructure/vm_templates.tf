resource "proxmox_virtual_environment_vm" "template" {
  name      = "template"
  node_name = var.proxmox_node
  template  = true
  started   = false
  agent {
    enabled = true
  }

  initialization {
     dns {
      servers = ["1.1.1.1"]
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    }

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
    import_from  = proxmox_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
}
