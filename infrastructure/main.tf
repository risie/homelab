data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/lab.pub")
}

resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name    = "jammy-server-cloudimg-amd64.qcow2"
}

resource "proxmox_virtual_environment_vm" "container_host" {
  name      = "container-host"
  node_name = var.proxmox_node

  cpu {
    cores = 6
    type  = "host"
  }

  memory {
    dedicated = 6144
  }

  network_device {
    bridge   = "vmbr0"
    firewall = false
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = 80
  }

  agent {
    enabled = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    dns {
      servers = ["1.1.1.1"]
    }

    user_data_file_id     = proxmox_virtual_environment_file.cloud_config.id
    network_data_file_id  = proxmox_virtual_environment_file.network_config.id
  }

  lifecycle {
    ignore_changes = [
      disk[0].import_from,
    ]
  }
}
