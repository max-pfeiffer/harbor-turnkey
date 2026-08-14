terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.12.0-alpha.5"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  # The bpg provider expects the API token as a single "<token_id>=<token_secret>" string
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true
}
