resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/templates/user-data-cloud-config.yaml", {
      hostname       = "k3s-node",
      ssh_public_key = trimspace(data.local_file.ssh_public_key.content)
    })
    file_name = "user-data-cloud-config.yaml"
  }
}
