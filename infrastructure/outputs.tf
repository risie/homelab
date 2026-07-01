output "server_ip" {
  value = module.k3s_server.vm_ip
  description = "Main server ip"
}

output "agent_ips" {
  value = [for agent in module.k3s_agent : agent.vm_ip]
}
