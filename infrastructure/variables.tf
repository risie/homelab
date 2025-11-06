variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://proxmox.local:8006/api2/json"
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "template_name" {
  description = "Name of the Ubuntu cloud image template"
  type        = string
  default     = "ubuntu-cloud-template"
}

variable "storage_pool" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for provisioning"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ssh_user" {
  description = "SSH user for cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "gateway" {
  description = "Network gateway"
  type        = string
  default     = "192.168.1.1"
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "8.8.8.8"
}

variable "server_ip" {
  description = "IP address for K3s server"
  type        = string
  default     = "192.168.1.100"
}

variable "agent_count" {
  description = "Number of K3s agent nodes"
  type        = number
  default     = 3
}

variable "agent_ips" {
  description = "IP addresses for K3s agent nodes"
  type        = list(string)
  default     = ["192.168.1.101", "192.168.1.102", "192.168.1.103"]
}
