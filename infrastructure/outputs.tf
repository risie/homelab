output "server_ip" {
  value = module.k3s_server.vm_ip
  description = "Main server ip"
}

