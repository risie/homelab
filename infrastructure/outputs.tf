locals {
  kubeconfig_path = "${path.cwd}/kubeconfig.yaml"
}

resource "terraform_data" "fetch_kubeconfig" {
  depends_on = [module.k3s_server]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for K3s server to be ready..."
      sleep 120
      echo "Fetching kubeconfig from ${var.server_ip}..."
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
        -i ~/.ssh/lab ubuntu@${var.server_ip} \
        'sudo cat /etc/rancher/k3s/k3s.yaml' | \
        sed 's/127.0.0.1/${var.server_ip}/g' > ${local.kubeconfig_path}
      chmod 600 ${local.kubeconfig_path}
      echo "Kubeconfig saved to ${local.kubeconfig_path}"
    EOT
  }
}

output "kubeconfig_path" {
  value       = local.kubeconfig_path
  description = "Path to kubeconfig file"
}

output "export_kubeconfig" {
  value       = "export KUBECONFIG=${local.kubeconfig_path}"
  description = "Run this command to use the cluster"
}

output "k3s_server_ip" {
  value       = var.server_ip
  description = "K3s server IP address"
}

output "kubectl_test" {
  value       = "kubectl --kubeconfig=${local.kubeconfig_path} get nodes"
  description = "Test command to verify cluster"
}
