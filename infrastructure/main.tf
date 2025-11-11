locals {
  server_ip_cidr = "${var.server_ip}/24"
  server_ip      = var.server_ip
}


resource "proxmox_virtual_environment_vm" "k3s_server" {
  name      = "k3sServer"
  node_name = var.proxmox_node
  agent {
    enabled = true
    timeout = "60s"
  }

  stop_on_destroy = false
  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloud_config_server.id

    ip_config {
      ipv4 {
        address = local.server_ip_cidr
        gateway = "192.168.68.1"
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
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
}

resource "proxmox_virtual_environment_vm" "k3s_agent" {
  count      = 3
  name       = "k3sAgent${count.index}"
  node_name  = var.proxmox_node
  depends_on = [proxmox_virtual_environment_vm.k3s_server]

  agent {
    enabled = true
    timeout = "60s"
  }
  stop_on_destroy = false

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloud_config_agent[count.index].id

    ip_config {
      ipv4 {
        address = "${var.agent_ips[count.index]}/24"
        gateway = "192.168.68.1"
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
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
}
