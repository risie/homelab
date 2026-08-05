resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/templates/cloud-config.yaml.tpl", {
      ssh_public_key = data.local_file.ssh_public_key.content
      hostname       = "container-host"
    })
    file_name = "container-host-cloud-config.cfg"
  }
}

resource "proxmox_virtual_environment_file" "network_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/templates/network-config.yaml.tpl", {})
    file_name = "container-host-network-config.cfg"
  }
}
