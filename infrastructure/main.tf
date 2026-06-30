locals {
  cidr_prefix_length = split("/", var.network_cidr)[1]
  gateway_ip         = cidrhost(var.network_cidr, 1)
  server_ip_only     = cidrhost(var.network_cidr, var.server_ip_offset)
  server_ip          = "${local.server_ip_only}/${local.cidr_prefix_length}"
  agent_ips = [
    for i in range(var.agent_count) : "${cidrhost(var.network_cidr, var.agent_ip_offset + i)}/${local.cidr_prefix_length}"
  ]
}

resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

# module "container-host" {
#   source             = "./modules/container-host"
#   proxmox_node_name          = var.proxmox_node
#   ip_address         = "192.168.105.0/24"
#   gateway_ip_address = local.gateway_ip
#   image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
# }

module "k3s_server" {
  source             = "./modules/k3s-vm"
  name               = "k3sServer"
  node_name          = var.proxmox_node
  ip_address         = local.server_ip
  gateway_ip_address = local.gateway_ip
  image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  cluster_init_server = true
}

module "k3s_agent" {
  source             = "./modules/k3s-vm"
  count              = 1 
  name               = "k3sAgent${count.index}"
  node_name          = var.proxmox_node
  server_ip_address =  local.server_ip
  ip_address         = local.agent_ips[count.index]
  gateway_ip_address = local.gateway_ip
  image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id

  depends_on = [module.k3s_server]
}
