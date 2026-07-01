variable "name" {
  type        = string
  description = "VM name"
}

variable "node_name" {
  type        = string
  description = "Proxmox node name"
}

variable "server_ip_address" {
  type        = string  
  nullable    = true
  default     = null
  description = "VM IP address without the CIDR or the of the server"
}

variable "ssh_public_key" {
  type        = string
  nullable    = false
  description = "The SSH key that will be used to manage the lab vms"
}

variable "vm_template_id" {
  type        = string
  description = "specifying which template to clone"
}

variable "cluster_init" {
  type        = bool
  default     = false
  description = "Creates a server node that initialise a new cluset"
}

