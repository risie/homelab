resource "random_pet" "k3s_vm_name" {}

locals {
  name = random_pet.k3s_vm_name.id
  k3s_token = "my-super-secret-shared-token-12345"
}


data "cloudinit_config" "k3s_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "os-bootstrap.yaml"
    content = templatefile("${path.module}/templates/os-bootstrap.yaml.tpl", {
      ssh_public_key = var.ssh_public_key
      hostname       = local.name
    })
  }

  part {
    content_type = "text/cloud-config"
    filename     = "k3s-config.yaml"
    content = templatefile("${path.module}/templates/k3s-config.yaml.tpl", {
      cluster_init = var.cluster_init
      k3s_token    = local.k3s_token
      server_ip    = var.server_ip_address
    })
  }

 part {
    content_type = "text/x-shellscript"
    filename     = "install-k3s.sh"
    content = templatefile("${path.module}/templates/install-k3s.sh.tpl", {
      cluster_init = var.cluster_init
    })
  }
}

resource "proxmox_virtual_environment_file" "k3s_cloud_init_snippet" {
  content_type = "snippets"
  datastore_id = "local" 
  node_name    = var.node_name

  source_raw {
    data      = data.cloudinit_config.k3s_config.rendered
    file_name = "k3s-${var.cluster_init ? "server" : "agent"}-config.cfg" 
  }
}

resource "proxmox_virtual_environment_vm"  "k3s_vm_clone" {
  name      = local.name
  node_name = var.node_name
  clone {
    vm_id = proxmox_virtual_environment_vm.k3s_vm_template.id
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.k3s_cloud_init_snippet.id
    }
  }

resource "proxmox_virtual_environment_vm" "k3s_vm_template" {
  name      = "template"
  node_name = var.node_name
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
    import_from  = var.image_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
}
