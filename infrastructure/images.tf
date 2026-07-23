resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name    = "jammy-server-cloudimg-amd64.qcow2"

  lifecycle {
  prevent_destroy = true
}

}
resource "proxmox_download_file" "parrot_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node 
  url          = "https://deb.parrot.sh/parrot/iso/7.3/Parrot-security-7.3_amd64.iso"

  lifecycle {
  prevent_destroy = true
}
}
