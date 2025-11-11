
resource "proxmox_virtual_environment_vm" "k3s_vm" {
  name      = var.name
  node_name = var.node_name
  agent {
    enabled = true
    timeout = "60s"
  }

  stop_on_destroy = false
  initialization {
    user_data_file_id = var.cloud_init_file.id

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway_ip_address
      }
    }
  }
  memory {
    dedicated = 2048
    floating  = 2048 # set equal to dedicated to enable ballooning
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
    import_from  = var.image_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
}
