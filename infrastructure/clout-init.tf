resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/lab.pub")
}

resource "proxmox_virtual_environment_file" "cloud_config_server" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/templates/user-data-server-cloud-config.yaml", {
      ssh_public_key = trimspace(data.local_file.ssh_public_key.content)
      k3s_token      = random_password.k3s_token.result
      ip             = local.server_ip_only
    })
    file_name = "user-data-server-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_agent" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/templates/user-data-agent-cloud-config.yaml", {
      ssh_public_key = trimspace(data.local_file.ssh_public_key.content)
      k3s_token      = random_password.k3s_token.result
      server_ip      = local.server_ip_only
    })
    file_name = "user-data-agent-cloud-config.yaml"
  }
}
