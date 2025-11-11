variable "name" {
  type        = string
  description = "VM name"
}

variable "node_name" {
  type        = string
  description = "Proxmox node name"
}

variable "ip_address" {
  type        = string
  description = "VM IP address with CIDR"
}

variable "gateway_ip_address" {
  type        = string
  description = "VM gateway IP address with CIDR"
}

variable "cloud_init_file" {
  type = object({
    id = string
  })
  description = "Proxmox cloud-init file resource"
}

variable "image_id" {
  type        = string
  description = "Cloud image ID from Proxmox"
}
