variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.xx.xxx:8006"
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

variable "network_cidr" {
  description = "Network CIDR for K3s cluster"
  type        = string
  default     = "192.168.xx.0/24"
}

variable "server_ip_offset" {
  description = "IP offset for K3s server"
  type        = number
  default     = 110
}

variable "agent_ip_offset" {
  description = "Starting IP offset for K3s agents"
  type        = number
  default     = 120
}

variable "agent_count" {
  description = "Number of K3s agent nodes"
  type        = number
  default     = 3
}
