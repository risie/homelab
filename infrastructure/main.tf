terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.username
  password = var.password
  insecure = true
  ssh {
    agent = true
  }
}
locals {
  server_ip = "192.168.68.111/24"
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
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

    ip_config {
      ipv4 {
        address = local.server_ip
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
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

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
