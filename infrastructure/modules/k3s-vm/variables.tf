variable "name" {
  type        = string
  description = "VM name"
}

variable "k3s_token" {
   type = string 
  sensitive = true
  default = "K10013f26d92a3f3d28e8d79a03f9bda1d247bdb863eb3030ca9a2d667cb089d434::3n39g3.fqmz8vbthx16xj0a"
}

variable "node_name" {
  type        = string
  description = "Proxmox node name"
}

variable "ip_address" {
  type        = string
  description = "VM IP address with CIDR"
}

variable "server_ip_address" {
  type        = string
  description = "VM IP address without the CIDR or the of the server"
  default = ""
}

variable "gateway_ip_address" {
  type        = string
  description = "VM gateway IP address with CIDR"
}
 
variable "image_id"{
  type = string
  description = "Id of the image to use in `import_from`"
}

variable "cluster_init_server" {
  type = bool
  default = false
  description = "Define if the node should init the cluster"
}
