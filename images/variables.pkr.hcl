/*
    DESCRIPTION:
    Ubuntu Server 25.04 LTS variables for Packer Builder for Proxmox (proxmox-iso).
*/

// Proxmox Connection Variables
variable "proxmox_url" {
  type        = string
  description = "The URL of the Proxmox server (e.g. 'https://192.168.1.100:8006/api2/json')"
}

variable "proxmox_username" {
  type        = string
  description = "The username to authenticate to Proxmox (e.g. 'root@pam' or 'user@pam!token_id')"
}

variable "proxmox_password" {
  type        = string
  description = "The password or API token secret to authenticate to Proxmox"
  sensitive   = true
}

variable "proxmox_insecure" {
  type        = bool
  description = "Skip TLS verification for Proxmox connection"
  default     = true
}

variable "proxmox_node" {
  type        = string
  description = "The name of the Proxmox node to build on"
}

variable "vm_version" {
  type        = string
  description = "The Ubuntu version (e.g. '25.04')"
  default     = "25.04"
}

variable "vm_hostname" {
  type        = string
  description = "The hostname for the template VM"
  default     = "ubuntu-template"
}

variable "vm_username" {
  type        = string
  description = "The default username for the VM"
  default     = "ubuntu"
}

variable "vm_password" {
  type        = string
  description = "The password for the default user (used for SSH during build)"
  sensitive   = true
}

variable "vm_password_hash" {
  type        = string
  description = "The hashed password for the default user (for cloud-init)"
  sensitive   = true
}

variable "vm_timezone" {
  type        = string
  description = "The timezone for the VM"
  default     = "UTC"
}

variable "vm_locale" {
  type        = string
  description = "The locale for the VM"
  default     = "en_US.UTF-8"
}

variable "vm_keyboard" {
  type        = string
  description = "The keyboard layout for the VM"
  default     = "us"
}

variable "vm_cpu_type" {
  type        = string
  description = "The CPU type (e.g. 'host', 'x86-64-v3')"
  default     = "x86-64-v3"
}

variable "vm_cpu_cores" {
  type        = number
  description = "The number of CPU cores"
  default     = 2
}

variable "vm_cpu_sockets" {
  type        = number
  description = "The number of CPU sockets"
  default     = 1
}

variable "vm_memory" {
  type        = number
  description = "The amount of memory in MB"
  default     = 2048
}

variable "vm_disk_size" {
  type        = string
  description = "The disk size (e.g. '32G')"
  default     = "32G"
}

variable "vm_storage_pool" {
  type        = string
  description = "The name of the storage pool for VM disks"
  default     = "local-lvm"
}

variable "vm_bridge" {
  type        = string
  description = "The network bridge to attach to"
  default     = "vmbr0"
}

variable "iso_storage" {
  type        = string
  description = "The storage location for ISO files"
  default     = "local"
}

variable "iso_path" {
  type        = string
  description = "The path to ISO files in the storage"
  default     = "iso"
}

variable "iso_file" {
  type        = string
  description = "The ISO filename"
  default     = "ubuntu-25.04-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "The ISO checksum (e.g. 'sha256:abc123...' or URL to checksum file)"
  default     = "https://releases.ubuntu.com/plucky/SHA256SUMS"
}
