terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.90.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.username
  password = var.password
  insecure = true
  # ssh {
  #   agent = true
  # }
}
