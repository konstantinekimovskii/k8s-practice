terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

# Подробнее https://registry.terraform.io/providers/bpg/proxmox/latest/docs#authentication
provider "proxmox" {
  alias    = "prox-lab"
  endpoint = var.prox-lab.endpoint
  insecure = var.prox-lab.insecure

  api_token = var.prox-lab_auth.api_token
  ssh {
    agent    = true
    username = var.prox-lab_auth.username
  }

  tmp_dir = "/var/tmp"
}