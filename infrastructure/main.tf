terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true
  # ssh {
  #   agent    = true
  #   username = "terraform"
  # }
}

# Generate a random K3s token for cluster authentication
resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.image_storage
  node_name    = var.proxmox_node
  url          = "http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

# # K3s Server (Control Plane)
# resource "proxmox_vm_qemu" "k3s_server" {
#   name        = "k3s-server"
#   target_node = var.proxmox_node
#   clone       = var.template_name
#   agent       = 1
#   os_type     = "cloud-init"
#   cores       = 2
#   sockets     = 1
#   cpu         = "host"
#   memory      = 4096
#   scsihw      = "virtio-scsi-pci"
#   bootdisk    = "scsi0"

#   # Disk configuration
#   disk {
#     slot     = 0
#     size     = "20G"
#     type     = "scsi"
#     storage  = var.storage_pool
#     iothread = 1
#   }

#   # Network configuration
#   network {
#     model  = "virtio"
#     bridge = "vmbr0"
#   }

#   # Cloud-init IP configuration
#   ipconfig0  = "ip=${var.server_ip}/24,gw=${var.gateway}"
#   nameserver = var.nameserver

#   # SSH keys
#   sshkeys = var.ssh_public_key

#   # Minimal cloud-init using snippets (no size limit)
#   cicustom = "user=local:snippets/k3s-server-user.yml"

#   lifecycle {
#     ignore_changes = [
#       network,
#     ]
#   }
# }

# # K3s Agent Nodes (Workers)
# resource "proxmox_vm_qemu" "k3s_agents" {
#   count       = var.agent_count
#   name        = "k3s-agent-${count.index + 1}"
#   target_node = var.proxmox_node
#   clone       = var.template_name
#   agent       = 1
#   os_type     = "cloud-init"
#   cores       = 2
#   sockets     = 1
#   cpu         = "host"
#   memory      = 4096
#   scsihw      = "virtio-scsi-pci"
#   bootdisk    = "scsi0"

#   # Disk configuration
#   disk {
#     slot     = 0
#     size     = "20G"
#     type     = "scsi"
#     storage  = var.storage_pool
#     iothread = 1
#   }

#   # Network configuration
#   network {
#     model  = "virtio"
#     bridge = "vmbr0"
#   }

#   # Cloud-init IP configuration
#   ipconfig0  = "ip=${var.agent_ips[count.index]}/24,gw=${var.gateway}"
#   nameserver = var.nameserver

#   # SSH keys
#   sshkeys = var.ssh_public_key

#   # Minimal cloud-init using snippets
#   cicustom = "user=local:snippets/k3s-agent-user.yml"

#   # Ensure server is created first
#   depends_on = [proxmox_vm_qemu.k3s_server]

#   lifecycle {
#     ignore_changes = [
#       network,
#     ]
#   }
# }

# # # Install K3s on server
# resource "null_resource" "k3s_server_install" {
#   # depends_on = [proxmox_vm_qemu.k3s_server]

#   connection {
#     type        = "ssh"
#     user        = var.ssh_user
#     private_key = file(var.ssh_private_key_path)
#     host        = var.server_ip
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "set -e",
#       "echo 'Waiting for cloud-init to complete...'",
#       "cloud-init status --wait || true",
#       "echo 'Installing K3s server...'",
#       "curl -sfL https://get.k3s.io | K3S_TOKEN='${random_password.k3s_token.result}' sh -s - server --disable=traefik --write-kubeconfig-mode=644",
#       "echo 'K3s server installation complete'",
#       "sudo kubectl get nodes"
#     ]
#   }
# }

# # Install K3s agents
# resource "null_resource" "k3s_agent_install" {
#   count = var.agent_count
#   # depends_on = [null_resource.k3s_server_install]

#   connection {
#     type        = "ssh"
#     user        = var.ssh_user
#     private_key = file(var.ssh_private_key_path)
#     host        = var.agent_ips[count.index]
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "set -e",
#       "echo 'Waiting for cloud-init to complete...'",
#       "cloud-init status --wait || true",
#       "echo 'Installing K3s agent...'",
#       "curl -sfL https://get.k3s.io | K3S_URL='https://${var.server_ip}:6443' K3S_TOKEN='${random_password.k3s_token.result}' sh -",
#       "echo 'K3s agent installation complete'"
#     ]
#   }
# }

# # Fetch kubeconfig from server
# resource "null_resource" "fetch_kubeconfig" {
#   # depends_on = [null_resource.k3s_agent_install]

#   provisioner "local-exec" {
#     command = <<-EOT
#       ssh -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no ${var.ssh_user}@${var.server_ip} 'sudo cat /etc/rancher/k3s/k3s.yaml' | \
#       sed 's/127.0.0.1/${var.server_ip}/g' > ${path.module}/kubeconfig.yaml
#       chmod 600 ${path.module}/kubeconfig.yaml
#     EOT
#   }
# }
