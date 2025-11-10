variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.68.100:8006"
}

variable "username" {
  description = "Proxmox API Token ID"
  type        = string
}

variable "password" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "proxmox"
}

variable "agent_ips" {
  description = "IP addresses for K3s agent nodes"
  type        = list(string)
  default     = ["192.168.68.101", "192.168.68.102", "192.168.68.103"]
}
