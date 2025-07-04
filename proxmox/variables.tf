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

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
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
  default = {
    ip_address    = "192.168.20.3"
    install_disk  = "/dev/vda"
    install_image = "factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.5"
    hostname      = "kubernetes-harbor"
  }
}



variable "network" {
  description = "Network for all nodes"
  type        = string
  default     = "192.168.20.0/24"
}

variable "network_gateway" {
  description = "Network gateway for all nodes"
  type        = string
  default     = "192.168.20.1"
}

variable "domain_name_server" {
  description = "DNS for all nodes"
  type        = string
  default     = "192.168.20.1"
}

variable "vip_shared_ip" {
  description = "Shared virtual IP address for control plane nodes"
  type        = string
  default     = "192.168.20.3"
}

variable "vlan_tag" {
  description = "Vlan tag for all nodes"
  type        = number
  default     = 20
}
