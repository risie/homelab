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
  image_id            = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}

module "k3s_agent" {
  source             = "./modules/k3s_vm"
  count              = 3
  name               = "agent${count.index}"
  server_ip_address  = module.k3s_server.vm_ip
  ssh_public_key     = data.local_file.ssh_public_key.content
  node_name          = var.proxmox_node
  image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
 }

