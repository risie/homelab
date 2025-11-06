output "k3s_server_ip" {
  description = "IP address of the K3s server"
  value       = var.server_ip
}

output "k3s_agent_ips" {
  description = "IP addresses of the K3s agent nodes"
  value       = var.agent_ips
}

output "k3s_token" {
  description = "K3s cluster token (sensitive)"
  value       = random_password.k3s_token.result
  sensitive   = true
}

output "cluster_info" {
  description = "K3s cluster information"
  value = {
    server_ip   = var.server_ip
    agent_count = var.agent_count
    agent_ips   = var.agent_ips
    kubeconfig  = "SSH to ${var.ssh_user}@${var.server_ip} and check /etc/rancher/k3s/k3s.yaml"
  }
}

output "ssh_commands" {
  description = "Useful SSH commands for cluster access"
  value = {
    server = "ssh ${var.ssh_user}@${var.server_ip}"
    agents = [for ip in var.agent_ips : "ssh ${var.ssh_user}@${ip}"]
  }
}

output "kubeconfig_command" {
  description = "Command to fetch kubeconfig"
  value       = "scp ${var.ssh_user}@${var.server_ip}:/etc/rancher/k3s/k3s.yaml ./kubeconfig.yaml && sed -i 's/127.0.0.1/${var.server_ip}/g' kubeconfig.yaml"
}
