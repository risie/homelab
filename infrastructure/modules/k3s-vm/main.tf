resource "random_pet" "k3s_vm_name" {}

locals {
  name = random_pet.k3s_vm_name.id
}


resource "proxmox_virtual_environment_file" "cloud_config_server_vm" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/templates/user-data-server-cloud-config.yaml", {
      ssh_public_key = trimspace(data.local_file.ssh_public_key.content)
      token      = var.k3s_token
      hostname       = local.name
     })
    file_name = "user-data-server-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_agent_vm" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/templates/user-data-agent-cloud-config.yaml", {
      ssh_public_key = trimspace(data.local_file.ssh_public_key.content)
      token      = k3s_token
      server_ip  = var.server_ip_address
      hostname       = local.name
     })
    file_name = "user-data-agent-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "k3s_vm" {
  name      = local.name
  node_name = var.node_name
  agent {
    enabled = true
    timeout = "60s"
  }

  initialization {
    user_data_file_id =  var.cluster_init_server ? proxmox_virtual_environment_file.cloud_config_server_vm.id : proxmox_virtual_environment_file.cloud_config_agent_vm.id

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
