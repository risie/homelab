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
    data      = trimspace(data.cloudinit_config.k3s_config.rendered)
    file_name = "k3s-${var.cluster_init ? "server" : "agent"}-${local.name}-config.cfg" 
 
  }
}

resource "proxmox_virtual_environment_vm"  "k3s_vm_clone" {
  name      = local.name
  node_name = var.node_name
  clone {
    vm_id = var.vm_template_id
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.k3s_cloud_init_snippet.id
    }
  }

