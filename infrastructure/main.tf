data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/lab.pub")
}

module "k3s_server" {
  source              = "./modules/k3s_vm"
  name                = "server"
  node_name           = var.proxmox_node
  ssh_public_key      = data.local_file.ssh_public_key.content
  cluster_init        = true
  vm_template_id      = proxmox_virtual_environment_vm.template.id
}

module "k3s_agent" {
  source             = "./modules/k3s_vm"
  count              = 1
  name               = "agent${count.index}"
  server_ip_address  = module.k3s_server.vm_ip
  ssh_public_key     = data.local_file.ssh_public_key.content
  node_name          = var.proxmox_node
  vm_template_id     = proxmox_virtual_environment_vm.template.id
 }


resource "proxmox_virtual_environment_vm" "parrot_security_vm" {
  name        = "parrot-security"
  node_name   = var.proxmox_node

  started     = false
  on_boot     = false 
  boot_order  = ["scsi0", "net0"]

  cpu {
    cores = 4
  }

  memory {
    dedicated = 4096
  }

  vga {
    type   = "qxl"
    memory = 32
  }

  network_device {
    bridge   = "vmbr0" 
    firewall = true   
  }

  disk {
    datastore_id = "local"
    file_id      = proxmox_download_file.parrot_iso.id
    interface    = "ide0"
  }

  disk {
    datastore_id = "local-lvm" 
    interface    = "scsi0"
    size         = 50 
    ssd          = true
  }
}

