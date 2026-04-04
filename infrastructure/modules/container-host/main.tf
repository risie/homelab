locals {
  name = random_pet.k3s_vm_name.id
}
resource "random_pet" "k3s_vm_name" {}

data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/lab.pub")
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  source_raw {
    data = templatefile("${path.module}/templates/user-data-cloud-config.yaml", {
      ssh_public_key = trimspace(data.local_file.ssh_public_key.content)
      hostname       = local.name
     })
    file_name = "user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "k3s_vm" {
  name      = name
  node_name = var.proxmox_node_name
  agent {
    enabled = true
    timeout = "60s"
  }
  initialization {
    user_data_file_id =  proxmox_virtual_environment_file.cloud_config.id
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway_ip_address
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
    import_from  = var.image_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
}
