locals {
  cidr_prefix_length = split("/", var.network_cidr)[1]
  gateway_ip         = cidrhost(var.network_cidr, 1)
  server_ip_only     = cidrhost(var.network_cidr, var.server_ip_offset)
  server_ip          = "${local.server_ip_only}/${local.cidr_prefix_length}"
  agent_ips = [
    for i in range(var.agent_count) : "${cidrhost(var.network_cidr, var.agent_ip_offset + i)}/${local.cidr_prefix_length}"
  ]
}

# K3s Server VM
module "k3s_server" {
  source             = "./modules/k3s-vm"
  name               = "k3sServer"
  node_name          = var.proxmox_node
  cloud_init_file    = proxmox_virtual_environment_file.cloud_config_server
  ip_address         = local.server_ip
  gateway_ip_address = local.gateway_ip
  image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}

# K3s Agent VMs
module "k3s_agent" {
  source             = "./modules/k3s-vm"
  count              = 3
  name               = "k3sAgent${count.index}"
  node_name          = var.proxmox_node
  cloud_init_file    = proxmox_virtual_environment_file.cloud_config_agent
  ip_address         = local.agent_ips[count.index]
  gateway_ip_address = local.gateway_ip
  image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}
