locals {
  kubeconfig_path = "${path.cwd}/kubeconfig.yaml"
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
  value       = local.server_ip_only
  description = "K3s server IP address"
}

output "k3s_agent_ips" {
  value       = local.agent_ips
  description = "K3s agent IP addresses"
}

output "kubectl_test" {
  value       = "kubectl --kubeconfig=${local.kubeconfig_path} get nodes"
  description = "Test command to verify cluster"
}

output "ip_allocation" {
  value = {
    network       = var.network_cidr
    gateway       = local.gateway_ip
    server        = local.server_ip_only
    server_offset = var.server_ip_offset
    agents        = [for ip in local.agent_ips : split("/", ip)[0]]
    agent_offset  = var.agent_ip_offset
  }
  description = "IP allocation map for the K3s cluster"
}
