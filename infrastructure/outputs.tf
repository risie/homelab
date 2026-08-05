output "container_host_ip" {
  value       = proxmox_virtual_environment_vm.container_host.ipv4_addresses[0][0]
  description = "Container host IP address"
}
