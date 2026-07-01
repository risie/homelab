resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/lab.pub")
}

# module "container-host" {
#   source             = "./modules/container-host"
#   proxmox_node_name          = var.proxmox_node
#   ip_address         = "192.168.105.0/24"
#   gateway_ip_address = local.gateway_ip
#   image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
# }

module "k3s_server" {
  source              = "./modules/k3s_vm"
  name                = "server"
  node_name           = var.proxmox_node
  ssh_public_key      = data.local_file.ssh_public_key.content
  cluster_init        = true
  vm_template_id     = proxmox_virtual_environment_vm.template.id
}

module "k3s_agent" {
  source             = "./modules/k3s_vm"
  count              = 3
  name               = "agent${count.index}"
  server_ip_address  = module.k3s_server.vm_ip
  ssh_public_key     = data.local_file.ssh_public_key.content
  node_name          = var.proxmox_node
  vm_template_id     = proxmox_virtual_environment_vm.template.id
 }

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name    = "jammy-server-cloudimg-amd64.qcow2"
}

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
