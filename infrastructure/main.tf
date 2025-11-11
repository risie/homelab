locals {
  server_ip_cidr = "${var.server_ip}/24"
  gateway_ip     = "192.168.68.1"
}

# K3s Server VM
module "k3s_server" {
  source = "./modules/k3s-vm"

  name               = "k3sServer"
  node_name          = var.proxmox_node
  cloud_init_file    = proxmox_virtual_environment_file.cloud_config_server
  ip_address         = local.server_ip_cidr
  gateway_ip_address = local.gateway_ip
  image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}

# K3s Agent VMs
module "k3s_agent" {
  source = "./modules/k3s-vm"
  count  = 3

  name               = "k3sAgent${count.index}"
  node_name          = var.proxmox_node
  cloud_init_file    = proxmox_virtual_environment_file.cloud_config_agent[count.index]
  ip_address         = "${var.agent_ips[count.index]}/24"
  gateway_ip_address = local.gateway_ip
  image_id           = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}
