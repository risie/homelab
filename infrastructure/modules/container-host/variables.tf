variable "proxmox_node_name" {
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
 
variable "image_id"{
  type = string
  description = "Id of the image to use in `import_from`"
}

