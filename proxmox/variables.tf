variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_target_node" {
  type = string
}

variable "proxmox_storage_device" {
  type = string
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    ip_address    = string
    install_disk  = string
    install_image = string
    hostname      = string
  })
}

variable "network" {
  description = "Network for all nodes"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway for all nodes"
  type        = string
}

variable "domain_name_server" {
  description = "DNS for all nodes"
  type        = string
}

variable "vlan_tag" {
  description = "Vlan tag for all nodes, default does not configure a Vlan"
  type        = number
  default     = 0
}
