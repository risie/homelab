locals {
  ssh_user = "ubuntu"
}

resource "random_password" "k3s_token" {
  length  = 32
  special = false
}


data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/lab.pub")
}

data "local_file" "ssh_private_key" {
  filename = pathexpand("~/.ssh/lab")
}

# Install K3s on server
resource "null_resource" "k3s_server_install" {
  depends_on = [proxmox_virtual_environment_vm.k3s_server]

  connection {
    type        = "ssh"
    user        = local.ssh_user
    private_key = trimspace(data.local_file.ssh_private_key.content)
    host        = local.server_ip
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait || true",
      "echo 'Installing K3s server...'",
      "curl -sfL https://get.k3s.io | K3S_TOKEN='${random_password.k3s_token.result}' sh -s - server --disable=traefik --write-kubeconfig-mode=644",
      "echo 'K3s server installation complete'",
      "sudo kubectl get nodes"
    ]
  }
}

# Install K3s agents
resource "null_resource" "k3s_agent_install" {
  count      = 3
  depends_on = [null_resource.k3s_server_install]

  connection {
    type        = "ssh"
    user        = local.ssh_user
    private_key = trimspace(data.local_file.ssh_private_key.content)
    host        = var.agent_ips[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait || true",
      "echo 'Installing K3s agent...'",
      "curl -sfL https://get.k3s.io | K3S_URL='https://${local.server_ip}:6443' K3S_TOKEN='${random_password.k3s_token.result}' sh -",
      "echo 'K3s agent installation complete'"
    ]
  }
}

# Fetch kubeconfig from server
resource "null_resource" "fetch_kubeconfig" {
  depends_on = [null_resource.k3s_server_install]

  provisioner "local-exec" {
    command = <<-EOT
ssh -i ${trimspace(data.local_file.ssh_private_key)} -o StrictHostKeyChecking=no ${local.ssh_user}@${local.server_ip} 'sudo cat /etc/rancher/k3s/k3s.yaml' | \
sed 's/127.0.0.1/${local.server_ip}/g' > ${path.module}/kubeconfig.yaml
chmod 600 ${path.module}/kubeconfig.yaml
EOT
  }
}
