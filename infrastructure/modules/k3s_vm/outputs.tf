output "vm_ip" {
  value       = proxmox_virtual_environment_vm.k3s_vm_clone.ipv4_addresses[1][0]
  description = "Vm IP address"
}
